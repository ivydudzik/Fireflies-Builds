extends RigidBody2D

@export var player: Node2D
@export var lifetime: float = 10.0

func _ready() -> void:
	if player == null:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]
	
	linear_velocity = (player.global_position - self.global_position).normalized() * get_parent().bulletSpeed
	
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.start()
	timer.timeout.connect(die)


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die()

func die() -> void:
	queue_free()
