class_name CellData
extends RefCounted

var kind: CellTypes.CellKind = CellTypes.CellKind.EMPTY

# Only valid if kind == TILE
var tile_state: CellTypes.TileState = CellTypes.TileState.BLACK_HIDDEN
var clue_type: CellTypes.ClueType = CellTypes.ClueType.NONE
var clue_number: int = -1

# Only valid if kind == COLUMN_CLUE
var column_dir: CellTypes.ColumnDirection = CellTypes.ColumnDirection.NONE
var column_number: int = -1

func is_radial() -> bool:
	return is_blue() and clue_type == CellTypes.ClueType.NORMAL

func is_hint() -> bool:
	return kind == CellTypes.CellKind.COLUMN_CLUE or \
		is_radial()

func is_blue() -> bool:
	return kind == CellTypes.CellKind.TILE and (
		tile_state == CellTypes.TileState.BLUE_REVEALED or
		tile_state == CellTypes.TileState.BLUE_HIDDEN
	)


func is_black() -> bool:
	return kind == CellTypes.CellKind.TILE and (
		tile_state == CellTypes.TileState.BLACK_HIDDEN or
		tile_state == CellTypes.TileState.BLACK_REVEALED
	)


func is_shown() -> bool:
	return kind == CellTypes.CellKind.TILE and (
		tile_state == CellTypes.TileState.BLUE_REVEALED or
		tile_state == CellTypes.TileState.BLACK_REVEALED
	)


func is_hidden() -> bool:
	return kind == CellTypes.CellKind.TILE and (
		tile_state == CellTypes.TileState.BLACK_HIDDEN or
		tile_state == CellTypes.TileState.BLUE_HIDDEN
	)


func is_revealed() -> bool:
	return is_shown()


func get_revealed_state() -> CellTypes.TileState:
	match tile_state:
		CellTypes.TileState.BLUE_HIDDEN:
			return CellTypes.TileState.BLUE_REVEALED
		CellTypes.TileState.BLACK_HIDDEN:
			return CellTypes.TileState.BLACK_REVEALED
		_:
			return tile_state


func _to_string() -> String:
	return "CellData: kind=%s, tile_state=%s, clue_type=%s, clue_number=%s, column_dir=%s, column_number=%s" % \
		[CellTypes.CellKind.keys()[kind], \
		CellTypes.TileState.keys()[tile_state], \
		CellTypes.ClueType.keys()[clue_type], \
		clue_number, \
		CellTypes.ColumnDirection.keys()[column_dir], \
		column_number]
