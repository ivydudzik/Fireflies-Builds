extends Node2D

# Light2D for glow
@export var light_node: Light2D

# Light area around player
@export var proximity_area: Area2D
var proximity_shape: CollisionShape2D
var proximity_circle: CircleShape2D

# ---------- Adjustable presets ----------
@export var RADIUS_NEUTRAL := 250.0
@export var ENERGY_NEUTRAL := 1.25

@export var RADIUS_FOCUSED := 50.0       # Left-click (small circle)
@export var ENERGY_FOCUSED := 1.75       # bright

@export var RADIUS_BROAD := 1500.0        # Right-click (large circle)
@export var ENERGY_BROAD := 0.5         # dim

# Lerp constants
const RADIUS_LERP_SPEED := 8.0
const ENERGY_LERP_SPEED := 8.0

const light_effect_offset := 200.0

# Current target values
var target_radius := RADIUS_NEUTRAL
var target_energy := ENERGY_NEUTRAL
var current_light_scale := 1.0


func _ready() -> void:
	# Get the shape as a CircleShape2D
	proximity_shape = proximity_area.get_node("CollisionShape2D") as CollisionShape2D
	proximity_circle = proximity_shape.shape as CircleShape2D
	
	if proximity_circle == null:
		push_error("CollisionShape2D does NOT contain a CircleShape2D!")
	

func _process(delta: float) -> void:
	# Always follows mouse
	global_position = get_global_mouse_position()

	# Change mode based on mouse input
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_set_state(RADIUS_FOCUSED, ENERGY_FOCUSED)
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		_set_state(RADIUS_BROAD, ENERGY_BROAD)
	else:
		_set_state(RADIUS_NEUTRAL, ENERGY_NEUTRAL)
		
	# Smooth radius transition (collision)
	var old_radius := proximity_circle.radius
	var new_radius: float = lerp(old_radius, target_radius, delta * RADIUS_LERP_SPEED)
	proximity_circle.radius = new_radius
	proximity_shape.shape = proximity_circle

	# Smooth energy transition
	light_node.energy = lerp(light_node.energy, target_energy, delta * ENERGY_LERP_SPEED)
	
	# Smooth light scale transition
	var target_scale: float = new_radius / light_effect_offset
	current_light_scale = lerp(current_light_scale, target_scale, delta * RADIUS_LERP_SPEED)
	light_node.scale = Vector2.ONE * current_light_scale


func _set_state(radius: float, energy: float) -> void:
	# Resize the visible area circle
	target_radius = radius

	# Adjust brightness
	target_energy = energy
