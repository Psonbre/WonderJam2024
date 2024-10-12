class_name PuzzlePiece
extends Area2D

@export var drag_speed := 10.0
@export var left_connection_slot := 0
@export var right_connection_slot := 0
@export var top_connection_slot := 0
@export var bottom_connection_slot := 0

@onready var left_bound = $PuzzlePiece/LeftBound
@onready var right_bound = $PuzzlePiece/RightBound
@onready var top_bound = $PuzzlePiece/TopBound
@onready var bottom_bound = $PuzzlePiece/BottomBound
@onready var sprite = $PuzzlePiece/Sprite2D

var has_attempted_connection_this_tick := false

var is_connected_left := false :
	set(value):
		$PuzzlePiece/LeftCollider/CollisionShape2D.disabled = value
var is_connected_right := false :
	set(value):
		$PuzzlePiece/RightCollider/CollisionShape2D.disabled = value
var is_connected_top := false :
	set(value):
		$PuzzlePiece/TopCollider/CollisionShape2D.disabled = value
var is_connected_bottom := false :
	set(value):
		$PuzzlePiece/BottomCollider/CollisionShape2D.disabled = value

var is_dragging := false
var is_hovering := false
var velocity := Vector2.ZERO
var default_scale := Vector2(1.0, 1.0)

var valid_drop := false
var start_drag_position := Vector2.ZERO

func _ready():
	default_scale = scale
	await get_tree().physics_frame
	await get_tree().physics_frame
	attempt_connection()
	
func _process(delta):
	if Input.is_action_just_pressed("Click") and is_hovering:
		start_dragging()
	elif Input.is_action_just_released("Click") and is_hovering and is_dragging:
		stop_dragging()
	
	if is_dragging:
		var target_position = get_global_mouse_position()
		var distance = target_position - global_position
		velocity = distance * drag_speed * delta
		global_position += velocity
		scale = scale.move_toward(default_scale * 1.1, 0.6 * delta)
		if velocity.length() > 0:
			var tilt_angle = velocity.x
			var max_tilt = deg_to_rad(10)
			tilt_angle = clamp(tilt_angle, -max_tilt, max_tilt)
			rotation = move_toward(rotation, tilt_angle, deg_to_rad(5) * delta * velocity.length())
	
	else:
		scale = scale.move_toward(default_scale, 2 * delta)
	
	has_attempted_connection_this_tick = false

func start_dragging():
	sprite.z_index = 10
	start_drag_position = position
	is_dragging = true
	set_puzzle_piece_collisions_to_foreground(true)
	for node in $PuzzlePiece/Content.get_children(false):
		set_collisions_to_foreground(node, true)
	attempt_connection()
	for piece in get_tree().get_nodes_in_group("PuzzlePieces"):
		if piece != self : piece.attempt_connection()
		
func stop_dragging():
	sprite.z_index = -1
	is_dragging = false
	set_puzzle_piece_collisions_to_foreground(false)
	for node in $PuzzlePiece/Content.get_children(true):
		set_collisions_to_foreground(node, false)
	for area in get_overlapping_areas():
		print(area)
	attempt_connection()
	for piece in get_tree().get_nodes_in_group("PuzzlePieces"):
		if piece != self : piece.attempt_connection()

func attempt_connection():
	if is_dragging : return
	if has_attempted_connection_this_tick: return
	has_attempted_connection_this_tick = true
	var other_piece
	is_connected_bottom = false
	is_connected_left = false
	is_connected_right = false
	is_connected_top = false
	
	# Check left bound
	other_piece = get_first_valid_overlap_in_bound(left_bound, "right")
	if other_piece != null && !other_piece.is_dragging:
		position = other_piece.position - Vector2(-200, 0)
		is_connected_left = true
		other_piece.is_connected_right = true
		scale = default_scale
		rotation = 0
		if has_node("PuzzlePiece/Content/Player"):
			get_node("PuzzlePiece/Content/Player").global_rotation = 0
	
	# Check right bound
	other_piece = get_first_valid_overlap_in_bound(right_bound, "left")
	if other_piece != null && !other_piece.is_dragging:
		position = other_piece.position - Vector2(200, 0)
		is_connected_right = true
		other_piece.is_connected_left = true
		scale = default_scale
		rotation = 0
		if has_node("PuzzlePiece/Content/Player"):
			get_node("PuzzlePiece/Content/Player").global_rotation = 0
	
	# Check top bound
	other_piece = get_first_valid_overlap_in_bound(top_bound, "bottom")
	if other_piece != null && !other_piece.is_dragging:
		position = other_piece.position - Vector2(0, -200)
		is_connected_top = true
		other_piece.is_connected_bottom = true
		scale = default_scale
		rotation = 0
		if has_node("PuzzlePiece/Content/Player"):
			get_node("PuzzlePiece/Content/Player").global_rotation = 0
	
	# Check bottom bound
	other_piece = get_first_valid_overlap_in_bound(bottom_bound, "top")
	if other_piece != null && !other_piece.is_dragging:
		position = other_piece.position - Vector2(0, 200)
		is_connected_bottom = true
		other_piece.is_connected_top = true
		scale = default_scale
		rotation = 0
		if has_node("PuzzlePiece/Content/Player"):
			get_node("PuzzlePiece/Content/Player").global_rotation = 0
	
func get_first_valid_overlap_in_bound(bound : Area2D, compatible_side : String):
	var overlapping_areas = bound.get_overlapping_areas()
	for area in overlapping_areas:
		var puzzle_piece = area.get_node("../..")
		if puzzle_piece is PuzzlePiece && puzzle_piece != self:
			if compatible_side == "left" && !puzzle_piece.is_connected_left && right_connection_slot + puzzle_piece.left_connection_slot == 0:
				return puzzle_piece
			if compatible_side == "right" && !puzzle_piece.is_connected_right && left_connection_slot + puzzle_piece.right_connection_slot == 0:
				return puzzle_piece
			if compatible_side == "top" && !puzzle_piece.is_connected_top && bottom_connection_slot + puzzle_piece.top_connection_slot == 0:
				return puzzle_piece
			if compatible_side == "bottom" && !puzzle_piece.is_connected_bottom && top_connection_slot + puzzle_piece.bottom_connection_slot == 0:
				return puzzle_piece
	return null

func _on_mouse_entered():
	is_hovering = true

func _on_mouse_exited():
	is_hovering = false

func set_puzzle_piece_collisions_to_foreground(foreground : bool):
	set_collisions_to_foreground(self, foreground)
	set_collisions_to_foreground($PuzzlePiece/LeftCollider, foreground)
	set_collisions_to_foreground($PuzzlePiece/RightCollider, foreground)
	set_collisions_to_foreground($PuzzlePiece/TopCollider, foreground)
	set_collisions_to_foreground($PuzzlePiece/BottomCollider, foreground)
	
	if foreground:
		is_connected_right = false
		is_connected_bottom = false
		is_connected_left = false
		is_connected_top = false

func set_collisions_to_foreground(node : CollisionObject2D, foreground : bool):
	node = node as CollisionObject2D
	if node == null : return
	node.set_collision_layer_value(4, foreground)
	node.set_collision_layer_value(1, !foreground)
	node.set_collision_mask_value(4, foreground)
	node.set_collision_mask_value(1, !foreground)

func _on_body_entered(player):
	if(player is Player && player.get_parent() != self):
		player.add_overlapping_piece(self)

func _on_body_exited(player):
	if(player is Player):
		player.remove_overlapping_piece(self)
