extends PanelContainer

@onready var vbox: VBoxContainer = $VBoxContainer

func update(units: Dictionary) -> void:
	for child in vbox.get_children():
		child.queue_free()
	for pid in PlayerManager.all_player_ids:
		var row = HBoxContainer.new()
		var dot = ColorRect.new()
		dot.custom_minimum_size = Vector2(12, 12)
		dot.color = get_player_color(pid)
		var label = Label.new()
		var count = units.values().filter(func(u): return u.player_id == pid).size()
		var is_you = " (you)" if pid == PlayerManager.player_local_id else ""
		label.text = "Player %d%s — %d units" % [pid, is_you, count]
		row.add_child(dot)
		row.add_child(label)
		vbox.add_child(row)

func get_player_color(pid: int) -> Color:
	var colors = [Color.RED, Color.BLUE, Color.GREEN, Color.YELLOW, Color.ORANGE, Color.PURPLE]
	return colors[pid % colors.size()]
