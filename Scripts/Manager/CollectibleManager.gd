extends Node
class_name CollectibleManager

var nbOfPiecesCaught : int = 12

func add_piece() -> void:
	nbOfPiecesCaught += 1
	
func remove_piece() -> void:
	nbOfPiecesCaught -= 1
	
func get_pieces_caught() -> int:
	return nbOfPiecesCaught
