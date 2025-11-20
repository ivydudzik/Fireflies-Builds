extends CharacterBody2D

signal died

@export var speed: float = 500
@export var max_exposure_time: float = 2.0
@export var recovery_rate: float = 2.0 # Multiplier for recovery speed
@export var vignette: ColorRect # Assign this in the inspector

var current_exposure: float = 0.0
var enemies_touching: int = 0

func _process(delta: float) -> void:
	var input_vector: Vector2 = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	
	global_position = global_position + input_vector.normalized() * delta * speed
	
	_process_exposure(delta)

func _process_exposure(delta: float) -> void:
	if enemies_touching > 0:
		current_exposure += delta
		if current_exposure >= max_exposure_time:
			die()
	else:
		current_exposure -= delta * recovery_rate
	
	current_exposure = clamp(current_exposure, 0.0, max_exposure_time)
	
	# Update Vignette Opacity
	if vignette:
		var opacity = current_exposure / max_exposure_time
		vignette.color.a = opacity * 0.8 # Max opacity 0.8

func start_contact() -> void:
	enemies_touching += 1

func end_contact() -> void:
	enemies_touching -= 1
	if enemies_touching < 0:
		enemies_touching = 0

func die() -> void:
	emit_signal("died")
	queue_free()
