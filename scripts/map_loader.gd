class_name MapLoader
extends RefCounted

static func load_from_file(path: String) -> Map:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open file: " + path)
		return null

	var raw_text := file.get_as_text().replace("\r", "")
	var lines := raw_text.split("\n", true)

	if lines.size() < 38:
		push_error("Invalid hexcells file (too few lines)")
		return null

	if lines[0] != "Hexcells level v1":
		push_error("Invalid hexcells file header")
		return null

	var map := Map.new()

	# Metadata
	map.title = lines[1]
	map.author = lines[2]
	map.description = lines[3] + "\n" + lines[4]

	# Grid (TRANSFORMED)
	for file_row in range(Map.SIZE):
		var line := lines[5 + file_row]

		if line.length() < Map.SIZE * 2:
			push_error("Invalid row %d" % file_row)
			return null

		for file_col in range(Map.SIZE):
			# skip padding cells
			if (file_col % 2) != (file_row % 2):
				continue

			var i := file_col * 2
			var pair := line.substr(i, 2)

			if pair.length() < 2:
				continue

			var cell := _parse_cell(pair)
			if cell == null:
				continue

			# transform coords
			var hex_col := file_col
			var hex_row := int((file_row - (file_row % 2)) / 2)

			# bounds check (important!)
			if hex_col < 0 or hex_col >= Map.SIZE:
				continue

			map.cells[hex_row][hex_col] = cell

	_initialize_numbers(map)
	return map

static func _initialize_numbers(map: Map) -> void:
	for row in range(Map.SIZE):
		for col in range(Map.SIZE):
			var cell := map.cells[row][col] as CellData
			if cell == null:
				continue

			match cell.kind:
				CellTypes.CellKind.TILE:
					cell.clue_number = _compute_tile_clue_number(map, col, row)

				CellTypes.CellKind.COLUMN_CLUE:
					cell.column_number = _compute_column_clue_number(map, col, row, cell.column_dir)

				_:
					pass

static func _compute_tile_clue_number(map: Map, col: int, row: int) -> int:
	var neighbors := map.get_neighbors(col, row)
	var count := 0

	for n in neighbors:
		if n.kind == CellTypes.CellKind.TILE and \
		(n.tile_state == CellTypes.TileState.BLUE_REVEALED or \
		n.tile_state == CellTypes.TileState.BLUE_HIDDEN):
			count += 1

	return count

static func _compute_column_clue_number(map: Map, col: int, row: int, direction: CellTypes.ColumnDirection) -> int:
	var line := map.get_line(col, row, direction)
	var count := 0

	for c in line:
		if c.kind == CellTypes.CellKind.TILE and \
		(c.tile_state == CellTypes.TileState.BLUE_REVEALED or \
		c.tile_state == CellTypes.TileState.BLUE_HIDDEN):
			count += 1

	return count

static func _parse_cell(pair: String) -> CellData:
	var type_char := pair[0]
	var mod_char := pair[1]

	if type_char == ".":
		return null

	var cell := CellData.new()

	match type_char:
		"o":
			cell.kind = CellTypes.CellKind.TILE
			cell.tile_state = CellTypes.TileState.BLACK_HIDDEN

		"O":
			cell.kind = CellTypes.CellKind.TILE
			cell.tile_state = CellTypes.TileState.BLACK_REVEALED

		"x":
			cell.kind = CellTypes.CellKind.TILE
			cell.tile_state = CellTypes.TileState.BLUE_HIDDEN

		"X":
			cell.kind = CellTypes.CellKind.TILE
			cell.tile_state = CellTypes.TileState.BLUE_REVEALED

		"\\":
			cell.kind = CellTypes.CellKind.COLUMN_CLUE
			cell.column_dir = CellTypes.ColumnDirection.DIAG_LEFT

		"|":
			cell.kind = CellTypes.CellKind.COLUMN_CLUE
			cell.column_dir = CellTypes.ColumnDirection.VERTICAL

		"/":
			cell.kind = CellTypes.CellKind.COLUMN_CLUE
			cell.column_dir = CellTypes.ColumnDirection.DIAG_RIGHT

		_:
			return null

	match mod_char:
		"+":
			cell.clue_type = CellTypes.ClueType.NORMAL

		"c":
			cell.clue_type = CellTypes.ClueType.CONSECUTIVE

		"n":
			cell.clue_type = CellTypes.ClueType.NON_CONSECUTIVE

		_:
			cell.clue_type = CellTypes.ClueType.NONE

	return cell
