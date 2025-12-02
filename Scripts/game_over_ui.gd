extends CanvasLayer

signal restart_clicked
signal menu_clicked

@onready var label: Label = $Control/ColorRect/Label
@onready var restart_button: Button = $Control/RestartButton
@onready var menu_button: Button = $Control/MenuButton

var player_died := true

var insults = [
	"Pathetic.",
	"Is that all?",
	"Disappointing.",
	"Tsk, try again.",
	"You can do better.",
	"Weakness disgusts me."
]

func _ready() -> void:
	# Pause the game when this screen appears
	get_tree().paused = true
	
	if label:
		if player_died:
			label.text = insults.pick_random()
		else:
			label.text = "Congrats. You proud?"
	
	if restart_button:
		if not restart_button.pressed.is_connected(_on_restart_pressed):
			restart_button.pressed.connect(_on_restart_pressed)
	
	if menu_button:
		if not menu_button.pressed.is_connected(_on_menu_pressed):
			menu_button.pressed.connect(_on_menu_pressed)

func _on_restart_pressed() -> void:
	print("Restart button pressed!")

	# Unpause the game
	get_tree().paused = false

	emit_signal("restart_clicked")

	queue_free()
	
func _on_menu_pressed() -> void:
	print("Menu button pressed!")

	# Unpause the game
	get_tree().paused = false

	emit_signal("menu_clicked")

	queue_free()


func _on_button_pressed() -> void:
	pass # Replace with function body.


func _on_restart_clicked() -> void:
	pass # Replace with function body.
