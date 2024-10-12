extends Label

var start_position

func _ready():
	start_position = global_position

func _process(delta):
	global_position = start_position + Vector2(cos(Time.get_unix_time_from_system()/2) * 15, sin(Time.get_unix_time_from_system() / 4) * 20)
	pass
