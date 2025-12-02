extends RigidBody2D

@export var speed: float = 100
var targets: Array[Node2D] = []
var target: Node2D = null

func _physics_process(_delta: float) -> void:
	target = get_best_target(targets)
	
	if target:
		var light := target.get_parent().get_node_or_null("Point Light")
		
		# Default fallback in case something goes wrong
		var brightness := 1.0
		
		if light:
			brightness = light.energy
		
		# Convert brightness into speed multiplier
		var speed_multiplier: float = clamp(brightness, 0.25, 3.0)
		
		# Move toward target
		var direction := (target.global_position - global_position).normalized()
		linear_velocity = direction * speed * speed_multiplier
	else:
		linear_velocity = Vector2.ZERO


func _on_light_detector_area_entered(area: Area2D) -> void:
	targets.append(area)


func _on_light_detector_area_exited(area: Area2D) -> void:
	targets.erase(area)

func get_best_target(target_array: Array[Node2D]) -> Node2D:
	var best_target: Node2D = null
	var best_score := -INF  # higher = better target
	
	for area in target_array:
		if area == null or area.get_parent() == null:
			continue
		
		# Get sibling light
		var light := area.get_parent().get_node_or_null("Point Light")
		if light == null:
			continue
		
		var brightness: float = light.energy  # Main brightness variable
		
		# Add inverse distance so closer bright lights score higher
		var distance := global_position.distance_to(area.global_position)
		var distance_factor: float = 1.0 / max(distance, 1.0)  # avoids division by zero
		
		# Final score
		var score := brightness * 1.0 + distance_factor * 0.1
		
		if score > best_score:
			best_score = score
			best_target = area
	
	return best_target


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("start_contact"):
		body.start_contact()

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("end_contact"):
		body.end_contact()
