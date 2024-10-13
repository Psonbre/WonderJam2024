extends Node



func _ready() -> void:
	var nbPieces : int = SubsystemManager.get_collectible_manager().get_pieces_caught()
	var pieces_array : Array[Node] = getPuzzlePieces()
	nbPieces = clamp(nbPieces, 0, pieces_array.size())
	for i in range(nbPieces):
		pieces_array[i].visible = true

func getPuzzlePieces() -> Array[Node]:
	var puzzle_pieces_array: Array[Node] = []
	
	for child in get_children():
		puzzle_pieces_array.append(child)
	
	return puzzle_pieces_array
