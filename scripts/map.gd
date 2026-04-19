class_name Map
extends RefCounted

const SIZE := 33

const EVEN_ROW_DIRS: Array[Vector2i] = [
			Vector2i(+1, -1), # up-right
			Vector2i(+1, 0),  # right
			Vector2i(0, +1),  # down
			Vector2i(-1, 0),  # left
			Vector2i(-1, -1), # up-left
			Vector2i(0, -1)   # up
		]

const ODD_ROW_DIRS: Array[Vector2i] = [
			Vector2i(+1, 0),  # right
			Vector2i(+1, +1), # down-right
			Vector2i(0, +1),  # down-left
			Vector2i(-1, +1), # down
			Vector2i(-1, 0),  # left
			Vector2i(0, -1)   # up
		]
		
const EVEN_Q_RADIUS2: Array[Vector2i] = [
	Vector2i(-2, -1), Vector2i(-2, 0), Vector2i(-2, 1),
	Vector2i(-1, -2), Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1),
	Vector2i(0, -2), Vector2i(0, -1), Vector2i(0, 1), Vector2i(0, 2),
	Vector2i(+1, -2), Vector2i(+1, -1), Vector2i(+1, 0), Vector2i(+1, 1),
	Vector2i(+2, -1), Vector2i(+2, 0), Vector2i(+2, 1)
]

const ODD_Q_RADIUS2: Array[Vector2i] = [
	Vector2i(-2, -1), Vector2i(-2, 0), Vector2i(-2, 1),
	Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(-1, 2),
	Vector2i(0, -2), Vector2i(0, -1), Vector2i(0, 1), Vector2i(0, 2),
	Vector2i(+1, -1), Vector2i(+1, 0), Vector2i(+1, 1), Vector2i(+1, 2),
	Vector2i(+2, -1), Vector2i(+2, 0), Vector2i(+2, 1)
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
	var dirs := EVEN_ROW_DIRS if (col % 2 == 0) else ODD_ROW_DIRS
	var result: Array[CellData] = []

	for d in dirs:
		var n := get_cell(col + d.x, row + d.y)
		result.append(n)

	return result
	
func get_radius2_neighbors(col: int, row: int) -> Array[CellData]:
	var dirs := EVEN_Q_RADIUS2 if (col % 2 == 0) else ODD_Q_RADIUS2
	var result: Array[CellData] = []

	for d in dirs:
		var cell := get_cell(col + d.x, row + d.y)
		if cell != null and cell.kind != CellTypes.CellKind.EMPTY:
			result.append(cell)

	return result

func get_line(col: int, row: int, direction: CellTypes.ColumnDirection) -> Array[CellData]:
	var result: Array[CellData] = []

	match direction:
		CellTypes.ColumnDirection.VERTICAL:
			for y in range(SIZE):
				var cell := get_cell(col, y)
				if cell != null and cell.kind != CellTypes.CellKind.EMPTY:
					result.append(cell)

		CellTypes.ColumnDirection.DIAG_RIGHT:
			var c := col
			var r := row

			while c >= 0 and r >= 0 and c < SIZE and r < SIZE:
				var cell := get_cell(c, r)
				if cell != null and cell.kind != CellTypes.CellKind.EMPTY:
					result.append(cell)

				# move down-left (odd-q vertical layout)
				if c % 2 == 0:
					c -= 1
				else:
					c -= 1
					r += 1

		CellTypes.ColumnDirection.DIAG_LEFT:
			var c := col
			var r := row

			while c >= 0 and r >= 0 and c < SIZE and r < SIZE:
				var cell := get_cell(c, r)
				if cell != null and cell.kind != CellTypes.CellKind.EMPTY:
					result.append(cell)

				# move down-right (odd-q vertical layout)
				if c % 2 == 0:
					c += 1
				else:
					c += 1
					r += 1

	return result
