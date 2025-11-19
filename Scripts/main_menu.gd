class_name MenuScene extends GameScene

signal gameStart
signal gameQuit

@onready var isStarted:bool = false

func _on_start_pressed() -> void:
	if isStarted:
		return
	emit_signal("gameStart")
	isStarted = true


func _on_quit_pressed() -> void:
	emit_signal("gameQuit")
