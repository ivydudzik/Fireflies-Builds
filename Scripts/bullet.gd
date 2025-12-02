extends RigidBody2D

@export var player: Node2D
@export var lifetime: float = 10.0
@export var bulletSpeed: float = 500.0
@export var bullet_dmg: float = 1.5

func _ready() -> void:
	# Find the player if not assigned
	if player == null:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]

	# Compute direction
	if player != null:
		linear_velocity = (player.global_position - global_position).normalized() * bulletSpeed

	# Lifetime timer
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.start()
	timer.timeout.connect(die)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if (body == player):
		player.hp -= bullet_dmg
		player.recovery_delay_timer = player.recovery_delay
	else:
		if body.has_method("die"):
			body.die()

func die() -> void:
	queue_free()
