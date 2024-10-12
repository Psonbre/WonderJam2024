extends Node
class_name LevelManager

func load_level(level_name: String) -> void:
	var packed_scene: PackedScene = ResourceLoader.load(level_name)

	if packed_scene != null:
		var new_level: Node = packed_scene.instantiate()
		SubsystemManager.get_SubsystemManager().root.add_child(new_level)

		var current_scene: Node = SubsystemManager.get_SubsystemManager().current_scene
		if current_scene != null:
			current_scene.queue_free() # Safely remove the current scene after the new one is added

		# Set the new scene as the active one
		SubsystemManager.get_SubsystemManager().current_scene = new_level
