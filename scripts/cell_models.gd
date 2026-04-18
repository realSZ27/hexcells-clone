extends Node
class_name CellTypes

enum CellKind {
	EMPTY,          # '.'
	TILE,           # o/O/x/X
	COLUMN_CLUE     # \ | /
}

enum TileState {
	BLACK_HIDDEN,   # o
	BLACK_REVEALED, # O
	BLUE_HIDDEN,    # x
	BLUE_REVEALED   # X
}

enum ClueType {
	NONE,              # .
	NORMAL,            # +
	CONSECUTIVE,       # c
	NON_CONSECUTIVE    # n
}

enum ColumnDirection {
	NONE,
	DIAG_LEFT,   # '\'
	VERTICAL,    # '|'
	DIAG_RIGHT   # '/'
}
