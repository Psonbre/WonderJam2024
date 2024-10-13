extends Label

var start_position

func _ready():
	start_position = position

func _process(delta):
	position = start_position + Vector2(cos(Time.get_unix_time_from_system()) * 15, sin(Time.get_unix_time_from_system() / 2) * 20)
	pass
