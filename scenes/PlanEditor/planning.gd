extends Control

# ── Configuration ────────────────────────────────────────────────
const BASE_URL         := "http://127.0.0.1:5000"
const GAME_ID          := "testgame"
const PLAYER_ID        := "testplayer"
const SCHEMA_VERSION   := "1.0"

const TAB_HEIGHT  := 32
const OPEN_HEIGHT := 350

const DSL_KEYWORDS := ["MoveTo", "Harvest", "Construct", "if", "END if", "END", "unit"]

# ── Plan state ───────────────────────────────────────────────────
enum State { DRAFT, ACTIVE, HISTORY }
var _state         := State.DRAFT
var _state_version := -1
var _loading_text  := false   # suppress text_changed → DRAFT during programmatic load
var _last_submitted_plan_json: String = ""

# ── Tab ──────────────────────────────────────────────────────────
var _active_tab    := 0        # 0 = Script, 1 = History
var _open          := false

# ── History ──────────────────────────────────────────────────────
var _history_data    : Array  = []
var _selected_ver    : int    = -1
var _pending_ver_load: int    = -1  # version we're currently fetching

# ── Node refs ────────────────────────────────────────────────────
@onready var script_tab_btn : Button        = $MainLayout/TabBar/ScriptTabBtn
@onready var history_tab_btn: Button        = $MainLayout/TabBar/HistoryTabBtn
@onready var state_chip     : Label         = $MainLayout/TabBar/StateChip
@onready var collapse_btn   : Button        = $MainLayout/TabBar/CollapseBtn

@onready var script_view    : VBoxContainer = $MainLayout/ContentStack/ScriptView
@onready var terminal       : CodeEdit      = $MainLayout/ContentStack/ScriptView/Terminal
@onready var submit_btn     : Button        = $MainLayout/ContentStack/ScriptView/ActionRow/SubmitBtn
@onready var status_label   : Label         = $MainLayout/ContentStack/ScriptView/ActionRow/StatusLabel
@onready var error_display  : RichTextLabel = $MainLayout/ContentStack/ScriptView/ErrorDisplay

@onready var history_view   : VBoxContainer = $MainLayout/ContentStack/HistoryView
@onready var refresh_btn    : Button        = $MainLayout/ContentStack/HistoryView/HistoryHeader/RefreshBtn
@onready var history_list   : VBoxContainer = $MainLayout/ContentStack/HistoryView/HistoryScroll/HistoryList
@onready var load_btn       : Button        = $MainLayout/ContentStack/HistoryView/HistoryFooter/LoadBtn
@onready var history_status : Label         = $MainLayout/ContentStack/HistoryView/HistoryFooter/HistoryStatus

var _http_submit : HTTPRequest
var _http_history: HTTPRequest
var _http_version: HTTPRequest
var _gateway_feedback_connected := false

var _last_compiled_json: String = ""

# ════════════════════════════════════════════════════════════════
func _ready() -> void:
	_http_submit  = _make_http()
	_http_history = _make_http()
	_http_version = _make_http()
	_http_submit.request_completed.connect(_on_submit_done)
	_http_history.request_completed.connect(_on_history_done)
	_http_version.request_completed.connect(_on_version_done)

	script_tab_btn.pressed.connect(func(): _switch_tab(0))
	history_tab_btn.pressed.connect(func(): _switch_tab(1))
	collapse_btn.pressed.connect(toggle)
	submit_btn.pressed.connect(_on_submit_pressed)
	refresh_btn.pressed.connect(_fetch_history)
	load_btn.pressed.connect(_on_load_pressed)
	terminal.text_changed.connect(_on_text_changed)
	terminal.code_completion_enabled = true

	_update_tab_style()
	_update_state_chip()
	_apply_open_state()

func _make_http() -> HTTPRequest:
	var h := HTTPRequest.new()
	add_child(h)
	return h

# ── Toggle ───────────────────────────────────────────────────────
func toggle() -> void:
	_open = !_open
	_apply_open_state()

func _apply_open_state() -> void:
	script_view.visible  = _open and (_active_tab == 0)
	history_view.visible = _open and (_active_tab == 1)
	offset_top = -OPEN_HEIGHT if _open else -TAB_HEIGHT
	collapse_btn.text = " ▼ " if _open else " ▲ "

# ── Tabs ─────────────────────────────────────────────────────────
func _switch_tab(tab: int) -> void:
	_active_tab = tab
	if _open:
		script_view.visible  = (tab == 0)
		history_view.visible = (tab == 1)
	_update_tab_style()
	if tab == 1 and _history_data.is_empty():
		_fetch_history()

func _update_tab_style() -> void:
	var active_col   := Color(1.0, 1.0, 1.0)
	var inactive_col := Color(0.5, 0.5, 0.55)
	script_tab_btn.add_theme_color_override("font_color",
		active_col if _active_tab == 0 else inactive_col)
	history_tab_btn.add_theme_color_override("font_color",
		active_col if _active_tab == 1 else inactive_col)

# ── Plan state chip ──────────────────────────────────────────────
func _set_state(s: State, version: int = -1) -> void:
	_state = s
	_state_version = version
	_update_state_chip()

func _update_state_chip() -> void:
	match _state:
		State.ACTIVE:
			state_chip.text = "  ●  Active  "
			state_chip.add_theme_color_override("font_color", Color(0.35, 0.85, 0.45))
		State.DRAFT:
			state_chip.text = "  ✎  Draft  "
			state_chip.add_theme_color_override("font_color", Color(0.95, 0.75, 0.25))
		State.HISTORY:
			state_chip.text = "  ↺  v%d  " % _state_version
			state_chip.add_theme_color_override("font_color", Color(0.45, 0.7, 1.0))

# ── Text change → Draft ──────────────────────────────────────────
func _on_text_changed() -> void:
	if _loading_text:
		return
	if _state != State.DRAFT:
		_set_state(State.DRAFT)
	_run_autocomplete()

func _run_autocomplete() -> void:
	var line   := terminal.get_caret_line()
	var col    := terminal.get_caret_column()
	var before := terminal.get_line(line).substr(0, col)
	var word   := before.lstrip(" \t")

	if word.begins_with("unit ") or word.begins_with("unit\t"):
		terminal.cancel_code_completion()
		return
	if word.is_empty() or " " in word or "\t" in word:
		terminal.cancel_code_completion()
		return
	for kw in DSL_KEYWORDS:
		if kw.to_lower().begins_with(word.to_lower()):
			terminal.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, kw, kw)
	terminal.update_code_completion_options(false)

# ── Submit ───────────────────────────────────────────────────────
func _on_submit_pressed() -> void:
	submit_btn.disabled = true
	_clear_feedback()
	var source := _build_header() + terminal.text
	var json   := _run_dsl(source)
	if json.is_empty():
		submit_btn.disabled = false
		return
	_last_compiled_json = json
	status_label.text = "Sending…"
	var err := _http_submit.request(
		BASE_URL + "/plan",
		["Content-Type: application/json"],
		HTTPClient.METHOD_POST, json)
	if err != OK:
		_show_error("[color=red]HTTP error %d — is the backend running on port 5000?[/color]" % err)

func _on_submit_done(result: int, code: int, _h: PackedStringArray, body: PackedByteArray) -> void:
	submit_btn.disabled = false
	var text := body.get_string_from_utf8()
	if result != HTTPRequest.RESULT_SUCCESS:
		_show_error("[color=red]Network error (code %d) — is backend running?[/color]" % result)
		return
	if code == 200:
		_clear_feedback()
		var executed := _execute_last_compiled_plan_locally()
		status_label.text = "  Plan accepted and executed" if executed else "  Plan accepted (not executed locally)"
		_set_state(State.ACTIVE)
		_history_data.clear()  # invalidate cache so next History visit refreshes
	elif code == 400:
		_show_error("[color=orange]Backend rejected the plan (400):[/color]\n" + text)
	else:
		_show_error("[color=orange]Unexpected response %d:[/color]\n" % code + text)

# ── DSL runner ───────────────────────────────────────────────────
func _build_header() -> String:
	return "Schema version: %s\nGame Id: %s\nPlayer Id: %s\n\n" % [
		SCHEMA_VERSION, GAME_ID, PLAYER_ID]

func _run_dsl(full_source: String) -> String:
	var input_abs  := ProjectSettings.globalize_path("user://dsl_input.txt")
	var output_abs := ProjectSettings.globalize_path("user://dsl_output.json")
	var dll_abs := (ProjectSettings.globalize_path("res://")+ "dsl/bin/Release/net8.0/dsl.dll").simplify_path()

	var f := FileAccess.open(input_abs, FileAccess.WRITE)
	if f == null:
		_show_error("[color=red]Error: could not open temp input file.[/color]")
		return ""
	f.store_string(full_source)
	f.close()

	var publish_exe := (ProjectSettings.globalize_path("res://") + "dsl/out/publish/dsl").simplify_path()
	var dev_dll := (ProjectSettings.globalize_path("res://") + "dsl/bin/Release/net8.0/dsl.dll").simplify_path()

	var out: Array = []
	var exit := -1
	
	if FileAccess.file_exists(publish_exe):
		exit = OS.execute(
			publish_exe,
			[input_abs, output_abs],
			out,
			true
		)
	else:
		exit = OS.execute(
			"dotnet",
			[dev_dll, input_abs, output_abs],
			out,
			true
		)
	if exit != 0:
		_show_error("[color=red]DSL parse error:[/color]\n" + "\n".join(out))
		return ""

	var f2 := FileAccess.open(output_abs, FileAccess.READ)
	if f2 == null:
		_show_error("[color=red]DSL produced no output file.[/color]")
		return ""
	var json := f2.get_as_text()
	f2.close()
	return json

# ── History fetch ────────────────────────────────────────────────
func _fetch_history() -> void:
	history_status.text = "Loading…"
	load_btn.disabled = true
	_selected_ver = -1
	var url := "%s/plan/%s/%s/history" % [BASE_URL, GAME_ID, PLAYER_ID]
	_http_history.request(url)

func _on_history_done(result: int, code: int, _h: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		history_status.text = "Could not load history (HTTP %d)." % code
		return

	var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
	if not parsed is Array:
		history_status.text = "Unexpected response format."
		return

	_history_data = parsed as Array
	history_status.text = ""
	_render_history()

func _render_history() -> void:
	for child in history_list.get_children():
		child.queue_free()
	_selected_ver = -1
	load_btn.disabled = true

	if _history_data.is_empty():
		var lbl := Label.new()
		lbl.text = "No history found."
		lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
		history_list.add_child(lbl)
		return

	for entry in _history_data:
		var ver      : int    = entry.get("version",   0)
		var is_active: bool   = entry.get("isActive",  false)
		var units    : int    = entry.get("unitCount",  0)
		var raw_date : String = entry.get("createdAt", "")
		var date_str : String = raw_date.substr(0, 10) if raw_date.length() >= 10 else "—"

		var label := "  v%d   %s   %d unit%s%s" % [
			ver, date_str, units, "" if units == 1 else "s",
			"   ● active" if is_active else ""]

		var btn := Button.new()
		btn.text      = label
		btn.flat      = true
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.add_theme_color_override("font_color",
			Color(0.35, 0.85, 0.45) if is_active else Color(0.8, 0.8, 0.85))
		btn.set_meta("ver", ver)
		btn.pressed.connect(_on_history_entry_pressed.bind(ver, btn))
		history_list.add_child(btn)

func _on_history_entry_pressed(ver: int, selected_btn: Button) -> void:
	_selected_ver = ver
	load_btn.disabled = false
	# Highlight selected, dim others — read version from meta, not from text
	for child in history_list.get_children():
		if not child is Button:
			continue
		var child_ver: int = child.get_meta("ver", -1)
		if child == selected_btn:
			child.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
		else:
			var active := false
			for e in _history_data:
				if e.get("version", -1) == child_ver:
					active = e.get("isActive", false)
					break
			child.add_theme_color_override("font_color",
				Color(0.35, 0.85, 0.45) if active else Color(0.5, 0.5, 0.55))

# ── Load version into editor ─────────────────────────────────────
func _on_load_pressed() -> void:
	if _selected_ver < 0:
		return
	_pending_ver_load = _selected_ver
	history_status.text = "Loading v%d…" % _selected_ver
	load_btn.disabled = true
	var url := "%s/plan/%s/%s/version/%d" % [BASE_URL, GAME_ID, PLAYER_ID, _selected_ver]
	_http_version.request(url)

func _on_version_done(result: int, code: int, _h: PackedStringArray, body: PackedByteArray) -> void:
	var ver := _pending_ver_load
	_pending_ver_load = -1

	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		history_status.text = "Failed to load v%d (HTTP %d)." % [ver, code]
		load_btn.disabled = false
		return

	var dsl_text := _decompile_plan(body.get_string_from_utf8())
	if dsl_text.is_empty():
		history_status.text = "Failed to decompile v%d." % ver
		load_btn.disabled = false
		return
	_loading_text = true
	terminal.text = dsl_text
	_loading_text = false

	# Determine whether the loaded version is the currently active one
	var is_active := false
	for e in _history_data:
		if e.get("version", -1) == ver:
			is_active = e.get("isActive", false)
			break

	_set_state(State.ACTIVE if is_active else State.HISTORY, ver)
	history_status.text = "Loaded v%d into editor." % ver
	load_btn.disabled = false
	_switch_tab(0)          # jump to Script tab to show the loaded code
	if not _open:
		toggle()

# ── JSON → DSL text (via DSL binary) ────────────────────────────
func _decompile_plan(json: String) -> String:
	var input_abs  := ProjectSettings.globalize_path("user://dsl_decompile_input.json")
	var output_abs := ProjectSettings.globalize_path("user://dsl_decompile_output.txt")
	var dll_abs := (ProjectSettings.globalize_path("res://") + "dsl/bin/Release/net8.0/dsl.dll").simplify_path()

	var f := FileAccess.open(input_abs, FileAccess.WRITE)
	if f == null:
		_show_error("[color=red]Error: could not open decompile temp file.[/color]")
		return ""
	f.store_string(json)
	f.close()

	var out: Array = []
	var exit := OS.execute("dotnet", [dll_abs, "--decompile", input_abs, output_abs], out, true)
	if exit != 0:
		_show_error("[color=red]Decompile error:[/color]\n" + "\n".join(out))
		return ""

	var f2 := FileAccess.open(output_abs, FileAccess.READ)
	if f2 == null:
		_show_error("[color=red]Decompiler produced no output.[/color]")
		return ""
	var dsl := f2.get_as_text()
	f2.close()
	return dsl

# ── Feedback helpers ─────────────────────────────────────────────
func _show_error(msg: String) -> void:
	status_label.text = ""
	error_display.visible = true
	error_display.text = msg

func _clear_feedback() -> void:
	status_label.text = ""
	error_display.visible = false
	error_display.text = ""

func _execute_last_compiled_plan_locally() -> bool:
	if _last_compiled_json.is_empty():
		return false
	var parsed: Variant = JSON.parse_string(_last_compiled_json)
	if not (parsed is Dictionary):
		return false
	var exec_plan := _convert_submission_to_exec_plan(parsed as Dictionary)
	var commands: Array = exec_plan.get("commands", [])
	if commands.is_empty():
		return false
	var gateway := _get_runtime_gateway()
	if gateway == null or not gateway.has_method("execute_plan"):
		return false
	_connect_gateway_feedback(gateway)
	return bool(gateway.call("execute_plan", exec_plan))

func _get_runtime_gateway() -> Node:
	var root := get_tree().get_root()
	if root.has_node("AdapterGateway"):
		return get_node_or_null("/root/AdapterGateway")
	if root.has_node("ActionGateway"):
		return get_node_or_null("/root/ActionGateway")
	return null

func _connect_gateway_feedback(gateway: Node) -> void:
	if _gateway_feedback_connected or gateway == null:
		return
	if gateway.has_signal("move_denied") and not gateway.is_connected("move_denied", Callable(self, "_on_move_denied")):
		gateway.connect("move_denied", Callable(self, "_on_move_denied"))
		_gateway_feedback_connected = true

func _on_move_denied(message: String) -> void:
	_show_error("[color=red]%s[/color]" % message)

func _convert_submission_to_exec_plan(submission: Dictionary) -> Dictionary:
	var commands: Array = []
	var unit_plans: Array = submission.get("unit_plans", [])
	for unit_plan in unit_plans:
		if not (unit_plan is Dictionary):
			continue
		var source_uid := int(unit_plan.get("unit_id", -1))
		var runtime_uid := _resolve_runtime_unit_id(source_uid)
		var steps: Array = unit_plan.get("steps", [])
		for step in steps:
			if not (step is Dictionary):
				continue
			var action_type := String(step.get("action_type", ""))
			var p: Dictionary = step.get("parameters", {})
			match action_type:
				"MoveTo":
					commands.append({
						"unit_id": runtime_uid,
						"action": "MOVE",
						"target": {
							"x": float(p.get("x", 0.0)),
							"y": float(p.get("y", 0.0))
						}
					})
				"Harvest":
					var harvest_cmd := {
						"unit_id": runtime_uid,
						"action": "HARVEST"
					}
					if p.has("target_id"):
						harvest_cmd["target_id"] = int(p.get("target_id", -1))
					if p.has("resource_type"):
						harvest_cmd["resource_type"] = String(p.get("resource_type", ""))
					commands.append(harvest_cmd)
				"Construct":
					commands.append({
						"unit_id": runtime_uid,
						"action": "CONSTRUCT",
						"scene": String(p.get("scene", "")),
						"position": {
							"x": float(p.get("x", 0.0)),
							"y": float(p.get("y", 0.0))
						},
						"duration": float(p.get("duration", 10.0))
					})
				_:
					pass
	return {"player_id": -1, "commands": commands}

func _resolve_runtime_unit_id(source_uid: int) -> int:
	if source_uid < 0:
		return source_uid
	var units := get_tree().get_nodes_in_group("units")
	for u in units:
		if is_instance_valid(u) and "entity_id" in u and int(u.entity_id) == source_uid:
			return source_uid
	if source_uid == 0 or source_uid > units.size():
		return source_uid
	var ordered: Array = []
	for u in units:
		if is_instance_valid(u) and "entity_id" in u:
			ordered.append(u)
	ordered.sort_custom(func(a, b): return int(a.entity_id) < int(b.entity_id))
	if source_uid - 1 >= 0 and source_uid - 1 < ordered.size():
		return int(ordered[source_uid - 1].entity_id)
	return source_uid