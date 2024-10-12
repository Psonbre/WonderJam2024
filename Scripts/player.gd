class_name Player
extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var overlapping_pieces = []


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	if overlapping_pieces.size() > 0 :
		var closest_piece = null
		var min_distance = INF
		for piece in overlapping_pieces:
			var distance = position.distance_to(piece.position)
			if distance < min_distance:
				min_distance = distance
				closest_piece = piece
		if closest_piece != null && (get_parent().get_parent().get_parent() == null || closest_piece != get_parent().get_node("../..")):
			reparent(closest_piece.get_node("PuzzlePiece/Content"))

func add_overlapping_piece(piece : PuzzlePiece):
	if piece not in overlapping_pieces:
		overlapping_pieces.push_back(piece)

func remove_overlapping_piece(piece : PuzzlePiece):
	if piece in overlapping_pieces:
		overlapping_pieces.remove_at(overlapping_pieces.find(piece))
