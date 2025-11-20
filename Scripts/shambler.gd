extends RigidBody2D

@export var speed: float = 100
var targets: Array[Node2D] = []
var target: Node2D = null

func _process(delta: float) -> void:
	target = get_closest_target(targets)
	if target:
		global_position = global_position + (target.global_position - global_position).normalized() * delta * speed


func _on_light_detector_area_entered(area: Area2D) -> void:
	targets.append(area)


func _on_light_detector_area_exited(area: Area2D) -> void:
	targets.erase(area)

func get_closest_target(target_array: Array[Node2D]):
	var closest_target: Node2D = null
	var closest_target_distance: float = INF
	for each_target in target_array:
		if global_position.distance_to(each_target.global_position) < closest_target_distance:
			closest_target = each_target
			closest_target_distance = global_position.distance_to(each_target.global_position)
			
	return closest_target


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("start_contact"):
		body.start_contact()

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("end_contact"):
		body.end_contact()
