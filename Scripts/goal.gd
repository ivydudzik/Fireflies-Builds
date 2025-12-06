class_name Goal extends Area2D

@export var goalPos1: Node2D
@export var goalPos2: Node2D
@export var goalPos3: Node2D

@export var initialGoalsRequired: int = 4
@export var numGoalsLeftToWin: int
var currentGoalPos: Node2D

signal level_won

func _ready() -> void:
	numGoalsLeftToWin = initialGoalsRequired
	currentGoalPos = goalPos1

func _on_body_entered(body: Node2D) -> void:
	# Check if the body is the player & if the goal has been reached enough times
	if (body.name == "Player" or body.has_method("start_contact")) && (numGoalsLeftToWin == 1): 
		emit_signal("level_won")
	else:
		move_goal()


func _on_level_won() -> void:
	pass # Replace with function body.

func move_goal() -> void:
	var rng = RandomNumberGenerator.new()
	var r = rng.randi_range(0, 2)
	
	match r:
		0:
			if (currentGoalPos == goalPos1):
				self.position = goalPos2.position
				currentGoalPos = goalPos2
			else:
				self.position = goalPos1.position
				currentGoalPos = goalPos1
		1:
			if (currentGoalPos == goalPos2):
				self.position = goalPos3.position
				currentGoalPos = goalPos3
			else:
				self.position = goalPos2.position
				currentGoalPos = goalPos2
		2:
			if (currentGoalPos == goalPos3):
				self.position = goalPos1.position
				currentGoalPos = goalPos1
			else:
				self.position = goalPos3.position
				currentGoalPos = goalPos3
		_:
			print("Goal error: random number generator failed.")
	
	numGoalsLeftToWin -= 1
