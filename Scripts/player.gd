class_name Player
extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var overlapping_pieces = []
var default_scale

func _ready():
	default_scale = global_scale
	animated_sprite_2d.play("Idle");

func reset_proportions():
	global_scale = default_scale
	rotation = 0
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED
		if (velocity.x  > 0) : animated_sprite_2d.flip_h = false
		elif (velocity.x < 0) : animated_sprite_2d.flip_h = true
		animated_sprite_2d.play("Moving");
		SubsystemManager.get_sound_manager().play_sound("res://Assets/Sounds/walk.ogg", -3)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor() : animated_sprite_2d.play("Idle");

	if Input.is_action_just_pressed("Jump") and is_on_floor():
		animated_sprite_2d.play("Jump");
		SubsystemManager.get_sound_manager().play_sound("res://Assets/Sounds/jump.ogg", -2)
		velocity.y = JUMP_VELOCITY

	move_and_slide()
	
	if overlapping_pieces.size() > 0 :
		var closest_piece = null
		var min_distance = INF
		for piece in overlapping_pieces:
			var distance = global_position.distance_to(piece.global_position)
			if distance < min_distance:
				min_distance = distance
				closest_piece = piece
		if closest_piece != null && (find_parent("Content") == null || closest_piece != get_parent().get_node("../..")):
			reparent(closest_piece.get_node("PuzzlePiece/Content"))
			reset_proportions()

func add_overlapping_piece(piece : PuzzlePiece):
	if piece not in overlapping_pieces:
		overlapping_pieces.push_back(piece)

func remove_overlapping_piece(piece : PuzzlePiece):
	if piece in overlapping_pieces:
		overlapping_pieces.remove_at(overlapping_pieces.find(piece))

func clamp_position_to_piece(piece : PuzzlePiece):
	#global_position = global_position.clamp(piece.global_position - Vector2(100 + 24 , 100 + 24), piece.global_position + Vector2(100 - 24,100 - 24))
	return
