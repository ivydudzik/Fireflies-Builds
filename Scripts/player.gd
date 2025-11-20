extends CharacterBody2D


# ---------- Initial Variables ----------
# Movement Tuning
@export var base_max_speed: float = 700.0
@export var acceleration: float = 2000.0
@export var friction: float = 1200.0
@export var momentum_turn_strength: float = 4.0  # Higher = snappier turns

# Flutter Motion Tuning
@export var flutter_amount: float = 0.12      # 0.05–0.2 recommended
@export var flutter_timer: float = 0.03    # How fast it wiggles


# ---------- Internal State ----------
var input_direction := Vector2.ZERO
var noise := FastNoiseLite.new()
var time_passed := 0.0

func _ready() -> void:
	# Seed noise for per-player natural variation
	noise.seed = randi()
	
func _process(delta: float) -> void:
	time_passed += delta

func _physics_process(delta: float) -> void:
	_get_input()
	_apply_inertia(delta)
	_apply_momentum(delta)
	_apply_flutter(delta)

	# Move the player using velocity property
	move_and_slide()
	


# ---------- Input Handling ----------
func _get_input() -> void:
	input_direction = Vector2.ZERO
	input_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_direction = input_direction.normalized()


# ---------- Glow-based Speed Handling ----------
# Player light dim = slow (stealthy), and bright = fast
func _get_current_max_speed() -> float:
	# Smoothly lerp between dim speed and bright speed
	return lerp(base_max_speed, 200.0, 0.5)


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
