class_name PuzzlePiece
extends Area2D

@export var drag_speed := 10.0
@export var left_connection_slot := 0
@export var right_connection_slot := 0
@export var top_connection_slot := 0
@export var bottom_connection_slot := 0

var can_connect_left := false
var can_connect_right := false
var can_connect_top := false
var can_connect_bottom := false

var is_connected_left := false
var is_connected_right := false
var is_connected_top := false
var is_connected_bottom := false

var is_dragging := false
var is_hovering := false
var velocity := Vector2.ZERO
var default_scale := Vector2(1.0, 1.0)

func _ready():
	default_scale = scale

func _process(delta):
	if Input.is_action_just_pressed("Click") and is_hovering:
		start_dragging()
	elif Input.is_action_just_released("Click"):
		stop_dragging()
	
	if is_dragging:
		var target_position = get_global_mouse_position()
		var distance = target_position - global_position
		velocity = distance * drag_speed * delta
		global_position += velocity

func start_dragging():
	scale *= 1.1 
	is_dragging = true
	set_collisions_to_foreground(self, true)
	set_collisions_to_foreground($PuzzlePiece/LeftCollider, true)
	set_collisions_to_foreground($PuzzlePiece/RightCollider, true)
	set_collisions_to_foreground($PuzzlePiece/TopCollider, true)
	set_collisions_to_foreground($PuzzlePiece/BottomCollider, true)
	for node in $PuzzlePiece/Content.get_children(false):
		set_collisions_to_foreground(node, true)
			
	for piece in get_tree().get_nodes_in_group("PuzzlePieces"):
		piece.update_connection_availability(self)
	
func stop_dragging():
	scale = default_scale
	is_dragging = false
	
	set_collisions_to_foreground(self, false)
	set_collisions_to_foreground($PuzzlePiece/LeftCollider, false)
	set_collisions_to_foreground($PuzzlePiece/RightCollider, false)
	set_collisions_to_foreground($PuzzlePiece/TopCollider, false)
	set_collisions_to_foreground($PuzzlePiece/BottomCollider, false)
	for node in $PuzzlePiece/Content.get_children(true):
		set_collisions_to_foreground(node, false)

func _on_mouse_entered():
	is_hovering = true

func _on_mouse_exited():
	is_hovering = false

func update_connection_availability(other_piece: PuzzlePiece):
	if other_piece == self : return
	
	can_connect_bottom = false
	can_connect_top = false
	can_connect_right = false
	can_connect_left = false
	
	if !is_connected_right:
		if other_piece.left_connection_slot + right_connection_slot == 0:
			can_connect_right = true
	if !is_connected_left:
		if other_piece.right_connection_slot + left_connection_slot == 0:
			can_connect_left = true
	if !is_connected_bottom:
		if other_piece.top_connection_slot + bottom_connection_slot == 0:
			can_connect_bottom = true
	if !is_connected_top:
		if other_piece.bottom_connection_slot + top_connection_slot == 0:
			can_connect_top = true
			
	$PuzzlePiece/LeftBound/Sprite2D.visible = can_connect_left
	$PuzzlePiece/BottomBound/Sprite2D.visible = can_connect_bottom
	$PuzzlePiece/RightBound/Sprite2D.visible = can_connect_right
	$PuzzlePiece/TopBound/Sprite2D.visible = can_connect_top


func _on_body_entered(body):
	if body is Player:
		call_deferred("deferred_reparent", body, $PuzzlePiece/Content)

func _on_body_exited(body):
	if body is Player and body.get_parent() == $PuzzlePiece/Content:
		call_deferred("deferred_reparent", body, get_tree().root)

func deferred_reparent(body, new_parent):
	body.reparent(new_parent)
	
func set_collisions_to_foreground(node : CollisionObject2D, foreground : bool):
	node = node as CollisionObject2D
	if node == null : return
	node.set_collision_layer_value(4, foreground)
	node.set_collision_layer_value(1, !foreground)
	node.set_collision_mask_value(4, foreground)
	node.set_collision_mask_value(1, !foreground)
