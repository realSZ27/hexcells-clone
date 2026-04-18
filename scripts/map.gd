class_name Map
extends RefCounted

const SIZE := 33

const EVEN_ROW_DIRS: Array[Vector2i] = [
	Vector2i(+1, 0), Vector2i(0, -1), Vector2i(-1, -1),
	Vector2i(-1, 0), Vector2i(-1, +1), Vector2i(0, +1)
]

const ODD_ROW_DIRS: Array[Vector2i] = [
	Vector2i(+1, 0), Vector2i(+1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(0, +1), Vector2i(+1, +1)
]

var title: String = ""
var author: String = ""
var description: String = ""

var cells: Array = []

func _init() -> void:
	cells.resize(SIZE)

	for row in range(SIZE):
		var row_cells: Array[CellData] = []
		row_cells.resize(SIZE)
		cells[row] = row_cells

static func from_file(path: String) -> Map:
	return MapLoader.load_from_file(path)

func get_cell(col: int, row: int) -> CellData:
	if col < 0 or col >= SIZE or row < 0 or row >= SIZE:
		return null
	return cells[row][col] as CellData

func for_each_cell(callback: Callable) -> void:
	for row in range(SIZE):
		for col in range(SIZE):
			var cell := cells[row][col] as CellData
			if cell != null:
				callback.call(cell, col, row)

func get_neighbors(col: int, row: int) -> Array[CellData]:
	var dirs := EVEN_ROW_DIRS if (row % 2 == 0) else ODD_ROW_DIRS
	var result: Array[CellData] = []

	for d in dirs:
		var n := get_cell(col + d.x, row + d.y)
		if n != null and n.kind != CellTypes.CellKind.EMPTY:
			result.append(n)

	return result

func get_line(col: int, row: int, direction: CellTypes.ColumnDirection) -> Array[CellData]:
	var result: Array[CellData] = []
	var key := _line_key(col, row, direction)

	if key == null:
		return result

	for y in range(SIZE):
		for x in range(SIZE):
			var cell := cells[y][x] as CellData
			if cell == null:
				continue

			if _line_matches(x, y, direction, key):
				result.append(cell)

	return result

func _line_key(col: int, row: int, direction: CellTypes.ColumnDirection) -> int:
	match direction:
		CellTypes.ColumnDirection.VERTICAL:
			return col

		# Matches your example: (0, 0), (1, 0), (2, 1), (3, 1), ...
		CellTypes.ColumnDirection.DIAG_RIGHT:
			@warning_ignore("integer_division")
			return int(col / 2) - row

		# Mirrored diagonal family.
		CellTypes.ColumnDirection.DIAG_LEFT:
			@warning_ignore("integer_division")
			return int((col + 1) / 2) - row

		_:
			return -1

func _line_matches(col: int, row: int, direction: CellTypes.ColumnDirection, key: int) -> bool:
	match direction:
		CellTypes.ColumnDirection.VERTICAL:
			return col == key

		CellTypes.ColumnDirection.DIAG_RIGHT:
			@warning_ignore("integer_division")
			return int(col / 2) - row == key

		CellTypes.ColumnDirection.DIAG_LEFT:
			@warning_ignore("integer_division")
			return int((col + 1) / 2) - row == key

		_:
			return false
