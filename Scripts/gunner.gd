extends RigidBody2D

@export var player: Node2D
@export var spotlight: Node2D

@export var shootDelay: float = 2.0
@export var shootingRange: float = 750.0

@onready var sprite: Sprite2D = $Sprite

var inRange: bool = false
var defused: bool = false
var shooting: bool = false
var bullet

func _ready() -> void:
	# Prevent gunner from being pushed around
	freeze = true
	
	bullet = load("res://Scenes/Components/bullet.tscn")
	
	if player == null:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]
			
	if (spotlight == null):
		spotlight = get_node_or_null("Spotlight")
		
	if spotlight == null or !is_instance_valid(spotlight):
		set_defused(false)
		return
	
	var shootTimer := Timer.new()
	add_child(shootTimer)
	shootTimer.wait_time = shootDelay
	shootTimer.start()
	shootTimer.timeout.connect(shoot)

func _physics_process(_delta: float) -> void:
	if player == null or !is_instance_valid(player):
		shooting = false
		inRange = false
		return
	
	if (!inRange):
		if ((player.position - self.position).length() < shootingRange):
			inRange = true
	else:
		if ((player.position - self.position).length() > shootingRange):
			inRange = false
			return
		
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(self.position, player.position)
		var result = space_state.intersect_ray(query)
		
		if ((result.collider == player) && !defused):
			shooting = true
		else:
			shooting = false
			
		if (shooting):
			# Point at player
			var target_angle = (player.global_position - global_position).angle() + deg_to_rad(90)
			rotation = lerp_angle(rotation, target_angle, 0.1)

func shoot() -> void:
	if shooting:
		var bullet_instance = bullet.instantiate()
		bullet_instance.global_position = global_position
		bullet_instance.player = player
		
		get_tree().get_current_scene().add_child(bullet_instance)

func set_defused(defused_state: bool) -> void:
	sprite.self_modulate = Color(0.25, 0.25, 0.5) if defused_state else Color(1, 1, 1) 
	defused = defused_state

func _on_light_detector_area_entered(area: Area2D) -> void:
	if (area == spotlight.proximity_area or area == player.proximity_area):
		set_defused(true)
		#print("Gunner defused!")

func _on_light_detector_area_exited(area: Area2D) -> void:
	if (area == spotlight.proximity_area or area == player.proximity_area):
		set_defused(false)
