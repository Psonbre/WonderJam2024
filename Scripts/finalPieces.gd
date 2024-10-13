extends Node

@onready var label = $"../piecesCaught"

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Jump"):
		test()

func _ready() -> void:
	var nbPieces : int = SubsystemManager.get_collectible_manager().get_pieces_caught()
	var pieces_array : Array[Node] = getPuzzlePieces()
	nbPieces = clamp(nbPieces, 0, pieces_array.size())
	label.text = str(nbPieces) +"/12 pieces"
	for i in range(nbPieces):
		pieces_array[i].visible = true

func getPuzzlePieces() -> Array[Node]:
	var puzzle_pieces_array: Array[Node] = []
	
	for child in get_children():
		puzzle_pieces_array.append(child)
	
	return puzzle_pieces_array
	
func test() -> void:
	for piece in get_tree().get_nodes_in_group("PuzzlePieces"):
		if piece is PuzzlePiece:
			var allSidesConnected = piece.has_all_sides_connected()
			print(piece.name + ": " + str(allSidesConnected))

func checkIfPuzzleComplete() -> void:
	for piece in get_tree().get_nodes_in_group("PuzzlePieces"):
		if piece is PuzzlePiece:
			!piece.has_all_sides_connected()
			return
	puzzleCompleted()
	
func puzzleCompleted() -> void:
	print("Puzzle completed")
