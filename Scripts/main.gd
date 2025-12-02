class_name SceneManager extends Node2D


@onready var transition: TransitionController = $"Transition Layer/AspectRatioContainer/Transition"

const SCENE_LOCATION = "res://Scenes/Levels/"
const LEVEL_NAME_PREFIX = "level_"
const SCENE_NAME_SUFFIX = ".tscn"

@export_category("Scene Management")
@export var startingScene: String
@export var mainMenuScene: String
@export var finalLevel: int

@export_category("Transitions")
@export var transition_time: float = 4

var currentSceneNode: Node
var currentLevel = 0

func _ready() -> void:
	# print(name + " is ready!")
	loadSceneByName(startingScene)
	transition.doOpenTransition(1)

func _process(_delta: float) -> void:
	if OS.has_feature("editor"):
		if Input.is_action_just_pressed("end_game"):
			quitGame()

func connect_signals(scene: GameScene) -> void:
	if scene is LevelScene:
		scene.levelReset.connect(reloadLevel)
		scene.levelComplete.connect(loadNextLevel)
	elif scene is MenuScene:
		scene.gameStart.connect(loadNextLevel)
		scene.gameQuit.connect(quitGame)
	elif scene is PrologueScene:
		scene.prologueEnd.connect(loadMainMenu)

#region Scene Management Methods
func quitGame() -> void:
	get_tree().quit(0)

func loadMainMenu():
	#  print("Loading " + mainMenuScene)
	switchToScene(mainMenuScene)

func loadNextLevel() -> void:
	currentLevel += 1
	if currentLevel > finalLevel:
		currentLevel = 0
		switchToScene("final_level")
	else:
		# print("load next level " + str(currentLevel))
		switchToLevel(currentLevel)

func reloadLevel() -> void:
	# print("reloading level")
	switchToLevel(currentLevel)

func switchToScene(sceneName: String) -> void:
	# print("switch to " + sceneName)
	transition.doTransition(transition_time)
	await transition.contents_hidden
	deleteChildScene(currentSceneNode)
	loadSceneByName(sceneName)

func switchToLevel(levelNumber: int) -> void:
	# print("switch to " + str(levelNumber))
	transition.doTransition(transition_time)
	await transition.contents_hidden
	deleteChildScene(currentSceneNode)
	loadSceneByLevelNumber(levelNumber)

func deleteChildScene(scene: Node):
	# print("delete child scene " + scene.name)
	scene.free()

func loadSceneByName(sceneName: String) -> void:
	# print("loading " + sceneName)
	loadScene(SCENE_LOCATION + sceneName + SCENE_NAME_SUFFIX)

func loadSceneByLevelNumber(number: int) -> void:
	# print("loading " + str(number))
	loadScene(SCENE_LOCATION + LEVEL_NAME_PREFIX + str(number) + SCENE_NAME_SUFFIX)

func loadScene(path: String) -> void:
	# print("load " + path)
	var new_scene_resource: Resource = load(path)
	if new_scene_resource == null:
		printerr("No level at '" + path + ",' loading main menu.")
		loadSceneByName(mainMenuScene)
		return
	var new_scene = new_scene_resource.instantiate()
	connect_signals(new_scene)
	currentSceneNode = new_scene
	add_child(new_scene)
	move_child(new_scene, 0)
#endregion
