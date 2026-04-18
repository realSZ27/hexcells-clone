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
