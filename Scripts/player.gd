extends CharacterBody2D
signal died


# ---------- Initial Variables ----------
# Movement Tuning
@export var base_max_speed: float = 450.0
@export var bright_max_speed: float = 100.0		# Speed when fully glowing
@export var acceleration: float = 2000.0
@export var friction: float = 1200.0
@export var momentum_turn_strength: float = 4.0	# Higher = snappier turns

# Flutter Motion Tuning
@export var flutter_amount: float = 0.12	# 0.05–0.2 recommended
@export var flutter_timer: float = 0.03		# How fast it wiggles

# Light2D for glow
@export var light_node: Light2D

# Light / Glow Tuning
@export var glow_min: float = 0.4	# Dimmest allowed brightness
@export var glow_max: float = 1.4	# Brightest possible
@export var glow_change_speed: float = 8.0	# How quickly brightness adjusts
@export var flicker_amount: float = 0.05	# Strength of flicker
@export var flicker_speed: float = 10.0		# How fast flicker updates

var glow_value: float = 1.0		# Current brightness
var target_glow: float = 1.0	# Where brightness is trying to go

# Player life variables
@export var max_hp: float = 2.5
@export var recovery_rate: float = 1.0		# Multiplier for recovery speed
@export var vignette: Sprite2D		# Assign this in the inspector
@export var enemy_quantity_dmg_mult: float = 0.01
@export var shambler_dmg: float = 1.0

var hp: float = 2.5
var enemies_touching: int = 0
@export var recovery_delay: float = 1.0
var recovery_delay_timer: float = 0.0

# Light area around player
@export var proximity_area: Area2D
var proximity_shape: CollisionShape2D
var proximity_circle: CircleShape2D
@export var detection_radius_min := 100.0
@export var detection_radius_max := 200.0
@export var light_visual_offset : float = 200.0


# ---------- Internal State ----------
var input_direction := Vector2.ZERO
var noise := FastNoiseLite.new()
var time_passed := 0.0
	
func _ready() -> void:
	add_to_group("player")
	hp = max_hp
	
	# Get the shape as a CircleShape2D
	proximity_shape = proximity_area.get_node("CollisionShape2D") as CollisionShape2D
	proximity_circle = proximity_shape.shape as CircleShape2D

	if proximity_circle == null:
		push_error("CollisionShape2D does NOT contain a CircleShape2D!")

func _physics_process(delta: float) -> void:
	time_passed += delta
	_get_input(delta)
	_apply_inertia(delta)
	_apply_momentum(delta)
	_apply_flutter(delta)
	_apply_glow(delta)
	_process_health(delta)

	# Move the player using velocity property
	move_and_slide()


# ---------- Input Handling ----------
func _get_input(delta: float) -> void:
	# Player direction
	input_direction = Vector2.ZERO
	input_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_direction = input_direction.normalized()
	
	# Increase glow
	if Input.is_action_pressed("glow_up"):
		target_glow = clamp(target_glow + 0.8 * delta, glow_min, glow_max)

	# Decrease glow
	if Input.is_action_pressed("glow_down"):
		target_glow = clamp(target_glow - 0.8 * delta, glow_min, glow_max)


# ---------- Glow-based Speed Handling ----------
# Player light dim = slow (stealthy), and bright = fast
func _get_current_max_speed() -> float:
	# Smoothly lerp between dim speed and bright speed
	return lerp(bright_max_speed, base_max_speed, glow_value)


# ---------- Glow Control ----------
func _apply_glow(delta: float) -> void:
	# Smooth glow transition toward target
	glow_value = lerp(glow_value, target_glow, delta * glow_change_speed)

	# Apply brightness to the Light2D node
	if light_node:
		light_node.energy = glow_value

		# Flicker light when glowing bright
		if glow_value > glow_min + 0.2:
			var flicker = noise.get_noise_1d(time_passed * flicker_speed) * flicker_amount
			light_node.energy += flicker
			
		# Scale proximity area with glow
		if proximity_circle:
			var t := inverse_lerp(glow_min, glow_max, glow_value)
			proximity_circle.radius = lerp(detection_radius_min, detection_radius_max, t)
			light_node.scale = Vector2.ONE * lerp(detection_radius_min / light_visual_offset, detection_radius_max / light_visual_offset, t)


# ---------- Intertia Force ----------
func _apply_inertia(delta: float) -> void:
	if input_direction.length() > 0:
		# Accelerate toward desired direction
		var target_velocity = input_direction * _get_current_max_speed()
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		# Slow down gradually
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)


# ---------- Momentum Preservation ----------
func _apply_momentum(delta: float) -> void:
	# Smoothly curve velocity toward input direction instead of snapping
	if input_direction.length() > 0:
		var desired_velocity = input_direction * velocity.length()
		velocity = velocity.lerp(desired_velocity, delta * momentum_turn_strength)


# ---------- Flutter Motion ----------
func _apply_flutter(delta: float) -> void:
	if velocity.length() < 20:
		return

	flutter_timer += delta

	# How often to snap (in seconds)
	if flutter_timer >= 0.03:  # ~30ms per snap (very fast)
		flutter_timer = 0.0

		# Sharp angle snap
		var snap_angle = randf_range(-0.25, 0.25)  # radians, ~20 degrees
		velocity = velocity.rotated(snap_angle)

		# Micro acceleration burst (hummingbird thrust)
		var burst_strength = randf_range(1.0, 1.08)
		velocity *= burst_strength

		# Slight overshoot clamp to avoid runaway speeds
		if velocity.length() > base_max_speed * 1.2:
			velocity = velocity.normalized() * base_max_speed * 1.2


# ---------- Player Damage ----------
func _process_health(delta: float) -> void:
	# Count down recovery delay timer
	recovery_delay_timer = max(recovery_delay_timer - delta, 0.0)
	#print(recovery_delay_timer)
	
	if enemies_touching > 0:
		hp -= (delta + (enemies_touching * enemy_quantity_dmg_mult)) * shambler_dmg
	else:
		if (recovery_delay_timer <= 0.0):
			hp += delta * recovery_rate
	
	if hp <= 0:
		die()
	
	hp = clamp(hp, 0.0, max_hp)
	
	# Update Vignette Opacity
	if vignette:
		var opacity = 1.0 - (hp / max_hp)
		vignette.modulate.a = opacity * 0.8 # Max opacity 0.8

func start_contact() -> void:
	enemies_touching += 1

func end_contact() -> void:
	enemies_touching -= 1
	if enemies_touching < 0:
		enemies_touching = 0
		
	recovery_delay_timer = recovery_delay

func die() -> void:
	emit_signal("died")
	queue_free()
