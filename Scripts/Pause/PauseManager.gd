extends Node

var is_paused : bool = false
@onready var pausePanel = $PausePanel

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		toggle_pause()

func _on_pause_button_pressed() -> void:
	toggle_pause()
	
func _on_resume_button_pressed() -> void:
	toggle_pause()

func _on_restart_button_pressed() -> void:
	toggle_pause()
	SubsystemManager.get_level_manager().reload_level()
	
func _on_quit_button_pressed() -> void:
	toggle_pause()
	SubsystemManager.get_level_manager().load_level("res://Scenes/MainMenu.tscn")

func toggle_pause() -> void:
	if !is_paused:
		is_paused = true
		Engine.time_scale = 0
		pausePanel.visible = true
	else:
		is_paused = false
		Engine.time_scale = 1
		pausePanel.visible = false
	
