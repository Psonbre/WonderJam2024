extends SceneTree
class_name SubsystemManager

static var instance: SubsystemManager = null
static var level_manager: LevelManager = null
static var music_manager: MusicManager = null


# Initialize the singleton instance
func _initialize() -> void:
	instance = Engine.get_main_loop() as SubsystemManager
	get_music_manager()

# Get the SubsystemManager singleton instance
static func get_SubsystemManager() -> SubsystemManager:
	if instance == null:
		instance = Engine.get_main_loop() as SubsystemManager
	return instance

# Get the LevelManager instance
static func get_level_manager() -> LevelManager:
	if level_manager == null:
		level_manager = LevelManager.new()
	return level_manager
	
# Get the MusicManager instance
static func get_music_manager() -> MusicManager:
	if music_manager == null:
		var music_manager_scene = load("res://Scenes/MusicManager.tscn")
		music_manager = music_manager_scene.instantiate()
		get_SubsystemManager().root.add_child(music_manager)
	return music_manager
