extends Control

# ── Configuration ────────────────────────────────────────────────
const BASE_URL         := "http://127.0.0.1:5020"
const DSL_DLL_RELATIVE := "dsl/bin/Release/net10.0/dsl.dll"
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
	status_label.text = "Sending…"
	var err := _http_submit.request(
		BASE_URL + "/plan",
		["Content-Type: application/json"],
		HTTPClient.METHOD_POST, json)
	if err != OK:
		_show_error("[color=red]HTTP error %d — is the backend running on port 5020?[/color]" % err)

func _on_submit_done(result: int, code: int, _h: PackedStringArray, body: PackedByteArray) -> void:
	submit_btn.disabled = false
	var text := body.get_string_from_utf8()
	if result != HTTPRequest.RESULT_SUCCESS:
		_show_error("[color=red]Network error (code %d) — is backend running?[/color]" % result)
		return
	if code == 200:
		_clear_feedback()
		status_label.text = "  ✓  Plan accepted"
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
	var dll_abs    := (ProjectSettings.globalize_path("res://") + DSL_DLL_RELATIVE).simplify_path()

	var f := FileAccess.open(input_abs, FileAccess.WRITE)
	if f == null:
		_show_error("[color=red]Error: could not open temp input file.[/color]")
		return ""
	f.store_string(full_source)
	f.close()

	var out: Array = []
	var exit := OS.execute("dotnet", [dll_abs, input_abs, output_abs], out, true)
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
	var dll_abs    := (ProjectSettings.globalize_path("res://") + DSL_DLL_RELATIVE).simplify_path()

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
