class_name MenuScene extends GameScene

signal gameStart
signal gameQuit

@onready var isStarted:bool = false

func _ready():
	get_tree().paused = false
	isStarted = false
	
	var startButton = get_node_or_null("CanvasLayer/Buttons/VBoxContainer/Play")
	if startButton:
		if not startButton.pressed.is_connected(_on_start_pressed):
			startButton.pressed.connect(_on_start_pressed)
	else:
		push_warning("StartButton node not found!")

func _on_start_pressed() -> void:
	if isStarted:
		return
	emit_signal("gameStart")
	isStarted = true


func _on_quit_pressed() -> void:
	emit_signal("gameQuit")
