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
@onready var sprite_outline = $Sprite/SpriteOutline
@onready var sprite_moving_outline = $Sprite/SpriteMovingOutline
@onready var content = $PuzzlePiece/Content

var has_attempted_connection_this_tick := false
var door
var collectible

var is_connected_left_to :
	set(value):
		$PuzzlePiece/LeftCollider/CollisionShape2D.disabled = value != null
		is_connected_left_to = value
		
var is_connected_right_to :
	set(value):
		$PuzzlePiece/RightCollider/CollisionShape2D.disabled = value != null
		is_connected_right_to = value
		
var is_connected_top_to :
	set(value):
		$PuzzlePiece/TopCollider/CollisionShape2D.disabled = value != null
		is_connected_top_to = value
				
var is_connected_bottom_to :
	set(value):
		$PuzzlePiece/BottomCollider/CollisionShape2D.disabled = value != null
		is_connected_bottom_to = value

var is_dragging := false
static var global_dragging := false
var is_hovering := false
var velocity := Vector2.ZERO
var default_scale := Vector2(1.0, 1.0)

var valid_drop := false
var start_drag_position := Vector2.ZERO

func _ready():
	default_scale = scale
	door = find_child("Door")
	collectible = find_child("Collectible")
	await get_tree().physics_frame
	await get_tree().physics_frame
	attempt_connection()
	
func _process(delta):
	if Input.is_action_just_pressed("Click") and is_hovering and !global_dragging:
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
	
func has_all_sides_connected():
	if is_connected_bottom_to == null && bottom_connection_slot != -2:
		return false
	if is_connected_left_to == null && left_connection_slot != -2:
		return false
	if is_connected_right_to == null && right_connection_slot != -2:
		return false
	if is_connected_top_to == null && top_connection_slot != -2:
		return false
	return true


func start_dragging():
	if Player.winning : return
	if get_tree().root.get_node("Game").old_screen != null : return
	sprite_moving_outline.visible = true
	z_index = 10
	start_drag_position = position
	is_dragging = true
	global_dragging = true
	SubsystemManager.get_sound_manager().play_sound("res://Assets/Sounds/piece_pickup.wav", -5.0)
	set_puzzle_piece_collisions_to_foreground(true)
	for node in content.get_children(false):
		set_collisions_to_foreground(node, true)
	var player = find_child("Player") as Player
	if player != null:
		player.set_physics_process(false)
	attempt_connection()
	for piece in get_tree().get_nodes_in_group("PuzzlePieces"):
		if piece != self : piece.attempt_connection()
		
func stop_dragging():
	sprite_moving_outline.visible = false
	z_index = -1
	is_dragging = false
	global_dragging = false
	set_puzzle_piece_collisions_to_foreground(false)
	for node in content.get_children(true):
		set_collisions_to_foreground(node, false)
	var player = find_child("Player") as Player
	await get_tree().physics_frame
	await get_tree().physics_frame
	for area in $PuzzlePieceOverlap.get_overlapping_areas():
		if area.get_parent() is PuzzlePiece and area.get_parent() != self:
			position = start_drag_position
			await get_tree().physics_frame
			attempt_connection()
			if player != null:
				await get_tree().physics_frame
				await get_tree().physics_frame
				player.set_physics_process(true)
			return
		
	attempt_connection()
	for piece in get_tree().get_nodes_in_group("PuzzlePieces"):
		if piece != self : piece.attempt_connection()
		
	if player != null:
		await get_tree().physics_frame
		await get_tree().physics_frame
		player.set_physics_process(true)

func attempt_connection():
	if is_dragging : return
	if has_attempted_connection_this_tick: return
	has_attempted_connection_this_tick = true
	var other_piece
	is_connected_bottom_to = null
	is_connected_left_to = null
	is_connected_right_to = null
	is_connected_top_to = null
	
	# Check left bound
	other_piece = get_first_valid_overlap_in_bound(left_bound, "right")
	if other_piece != null && !other_piece.is_dragging:
		if get_parent() != other_piece.get_parent() : return
		if scale != default_scale:
			SubsystemManager.get_sound_manager().play_sound("res://Assets/Sounds/piece_click.ogg", -10.0)
		position = other_piece.position - Vector2(-200, 0)	
		is_connected_left_to = other_piece
		other_piece.is_connected_right_to = self
		scale = default_scale
		rotation = 0
		if has_node("PuzzlePiece/Content/Player"):
			get_node("PuzzlePiece/Content/Player").reset_proportions()
	
	# Check right bound
	other_piece = get_first_valid_overlap_in_bound(right_bound, "left")
	if other_piece != null && !other_piece.is_dragging:
		if get_parent() != other_piece.get_parent() : return
		if scale != default_scale:
			SubsystemManager.get_sound_manager().play_sound("res://Assets/Sounds/piece_click.ogg", -10.0)
		position = other_piece.position - Vector2(200, 0)
		is_connected_right_to = other_piece
		other_piece.is_connected_left_to = self
		scale = default_scale
		rotation = 0
		if has_node("PuzzlePiece/Content/Player"):
			get_node("PuzzlePiece/Content/Player").reset_proportions()
	
	# Check top bound
	other_piece = get_first_valid_overlap_in_bound(top_bound, "bottom")
	if other_piece != null && !other_piece.is_dragging:
		if get_parent() != other_piece.get_parent() : return
		if scale != default_scale:
			SubsystemManager.get_sound_manager().play_sound("res://Assets/Sounds/piece_click.ogg", -10.0)
		position = other_piece.position - Vector2(0, -200)
		is_connected_top_to = other_piece
		other_piece.is_connected_bottom_to = self
		scale = default_scale
		rotation = 0
		if has_node("PuzzlePiece/Content/Player"):
			get_node("PuzzlePiece/Content/Player").reset_proportions()
	
	# Check bottom bound
	other_piece = get_first_valid_overlap_in_bound(bottom_bound, "top")
	if other_piece != null && !other_piece.is_dragging:
		if get_parent() != other_piece.get_parent() : return
		if scale != default_scale:
			SubsystemManager.get_sound_manager().play_sound("res://Assets/Sounds/piece_click.ogg", -10.0)
		position = other_piece.position - Vector2(0, 200)
		is_connected_bottom_to = other_piece
		other_piece.is_connected_top_to = self
		scale = default_scale
		rotation = 0
		if has_node("PuzzlePiece/Content/Player"):
			get_node("PuzzlePiece/Content/Player").reset_proportions()
	
func get_first_valid_overlap_in_bound(bound : Area2D, compatible_side : String):
	var overlapping_areas = bound.get_overlapping_areas()
	for area in overlapping_areas:
		var puzzle_piece = area.get_node("../..")
		if puzzle_piece is PuzzlePiece && puzzle_piece != self:
			if compatible_side == "left" && (puzzle_piece.is_connected_left_to == null || puzzle_piece.is_connected_left_to == self) && right_connection_slot + puzzle_piece.left_connection_slot == 0:
				return puzzle_piece
			if compatible_side == "right" && (puzzle_piece.is_connected_right_to == null || puzzle_piece.is_connected_right_to == self) && left_connection_slot + puzzle_piece.right_connection_slot == 0:
				return puzzle_piece
			if compatible_side == "top" && (puzzle_piece.is_connected_top_to == null || puzzle_piece.is_connected_top_to == self) && bottom_connection_slot + puzzle_piece.top_connection_slot == 0:
				return puzzle_piece
			if compatible_side == "bottom" && (puzzle_piece.is_connected_bottom_to == null || puzzle_piece.is_connected_bottom_to == self) && top_connection_slot + puzzle_piece.bottom_connection_slot == 0:
				return puzzle_piece
	return null

func _on_mouse_entered():
	is_hovering = true
	if !global_dragging:
		z_index = 3

func _on_mouse_exited():
	is_hovering = false
	if !is_dragging:
		z_index = -1

func set_puzzle_piece_collisions_to_foreground(foreground : bool):
	set_collisions_to_foreground(self, foreground)
	set_collisions_to_foreground($PuzzlePiece/LeftCollider, foreground)
	set_collisions_to_foreground($PuzzlePiece/RightCollider, foreground)
	set_collisions_to_foreground($PuzzlePiece/TopCollider, foreground)
	set_collisions_to_foreground($PuzzlePiece/BottomCollider, foreground)
	set_collisions_to_foreground($Collisions, foreground)
	
	if foreground:
		set_collisions_to_foreground(door, foreground)
		set_collisions_to_foreground(collectible, foreground)
		is_connected_right_to = null
		is_connected_bottom_to = null
		is_connected_left_to = null
		is_connected_top_to = null
	else:
		await get_tree().physics_frame
		await get_tree().physics_frame
		set_collisions_to_foreground(door, foreground)
		set_collisions_to_foreground(collectible, foreground)
		

func set_collisions_to_foreground(node : CollisionObject2D, foreground : bool):
	if node == null : return
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
