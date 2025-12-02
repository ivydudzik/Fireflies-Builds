extends RigidBody2D

@export var player: Node2D
@export var spotlight: Node2D

@export var shootDelay: float = 2.0
@export var shootingRange: float = 750.0
@export var bulletSpeed: float = 250.0

var inRange: bool = false
var defused: bool = false
var shooting: bool = false
var bullet

func _ready() -> void:
	bullet = load("res://Scenes/Components/bullet.tscn")
	
	if player == null:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]
			
	if (spotlight == null):
		spotlight = get_node("Spotlight")
	
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

func shoot() -> void:
	if (shooting):
		#print("Gunner took a shot!")
		var bullet_instance = bullet.instantiate()
		bullet_instance.set_name("bullet")
		add_child(bullet_instance)

func _on_light_detector_area_entered(area: Area2D) -> void:
	if (area == spotlight.proximity_area):
		defused = true
		#print("Gunner defused!")

func _on_light_detector_area_exited(area: Area2D) -> void:
	if (area == spotlight.proximity_area):
		defused = false
