class_name LevelScene extends GameScene

signal levelComplete
signal levelReset

func _on_goal_level_won() -> void:
	emit_signal("levelComplete")


func _on_player_died() -> void:
	emit_signal("levelReset")
 
