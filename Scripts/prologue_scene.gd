class_name PrologueScene extends GameScene

signal prologueEnd

func end_prologue() -> void:
	emit_signal("prologueEnd")
