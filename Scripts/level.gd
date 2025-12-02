class_name LevelScene extends GameScene

signal levelComplete
signal levelReset

@export var game_over_ui_scene: PackedScene

func _on_goal_level_won() -> void:
	if game_over_ui_scene:
		var ui = game_over_ui_scene.instantiate()
		ui.player_died = false
		add_child(ui)
		# Connect the UI's restart signal to our levelReset signal
		ui.restart_clicked.connect(func(): emit_signal("levelReset"))
		ui.menu_clicked.connect(func(): emit_signal("levelComplete"))
	else:
		emit_signal("levelComplete")

func _on_player_died() -> void:
	if game_over_ui_scene:
		var ui = game_over_ui_scene.instantiate()
		ui.player_died = true
		add_child(ui)
		# Connect the UI's restart signal to our levelReset signal
		ui.restart_clicked.connect(func(): emit_signal("levelReset"))
		ui.menu_clicked.connect(func(): emit_signal("levelComplete"))
	else:
		emit_signal("levelReset")


func _on_goal_body_entered(body: Node2D) -> void:
	# Check for Player by name or by a unique method they have
	if body.name == "Player" or body.has_method("start_contact"):
		_on_goal_level_won()
