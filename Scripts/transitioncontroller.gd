class_name TransitionController extends ColorRect

var TRANSITIONMATERIAL : Resource

@export var open_transition_type : Tween.TransitionType
@export var close_transition_type : Tween.TransitionType
@export var open_ease_type : Tween.EaseType
@export var close_ease_type : Tween.EaseType

signal transition_start
signal contents_hidden
signal transition_end

func _ready() -> void:
	TRANSITIONMATERIAL = material

func doTransition(time):
	emit_signal("transition_start")
	await doCloseTransition(time/2)
	emit_signal("contents_hidden")
	await doOpenTransition(time/2)
	emit_signal("transition_end")

func doOpenTransition(time):
	var transitiontween : Tween = create_tween() #.set_loops(transition_steps)
	TRANSITIONMATERIAL.set_shader_parameter("shader_parameter/progress", 0)
	transitiontween.tween_property(TRANSITIONMATERIAL, "shader_parameter/progress", 2.75, time).set_trans(open_transition_type).set_ease(open_ease_type)
	await transitiontween.finished
	# tween_callback(setFeather).bind(transitiontween.).delay(time / float(transition_steps))

func doCloseTransition(time):
	var transitiontween : Tween = create_tween() #.set_loops(transition_steps)
	TRANSITIONMATERIAL.set_shader_parameter("shader_parameter/progress", 2.75)
	transitiontween.tween_property(TRANSITIONMATERIAL, "shader_parameter/progress", 0, time).set_trans(close_transition_type).set_ease(close_ease_type)
	await transitiontween.finished
	# tween_callback(setFeather).bind(transitiontween.).delay(time / float(transition_steps))
