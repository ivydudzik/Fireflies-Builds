class_name Goal extends Area2D

signal level_won

func _on_body_entered(body: Node2D) -> void:
	# Check if the body is the player
	if body.name == "Player" or body.has_method("start_contact"): 
		emit_signal("level_won")


func _on_level_won() -> void:
	pass # Replace with function body.
