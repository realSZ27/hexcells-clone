extends Node2D

var CELL_DATA: CellData

@onready var hexagon := $Hexagons/Hexagon
@onready var inner_hexagon := $Hexagons/InnerHexagon

func _ready() -> void:
	if CELL_DATA == null:
		return
	
	set_hints()
	set_cell_color()

func set_hints() -> void:
	if CELL_DATA.kind == CellTypes.CellKind.TILE and \
	CELL_DATA.clue_type != CellTypes.ClueType.NONE and \
	!CELL_DATA.is_hidden():
		var label := $Labels/CenterLabel
		label.visible = true
		
		var clue_num_str := str(CELL_DATA.clue_number)
		if CELL_DATA.clue_type == CellTypes.ClueType.NORMAL:
			label.text = clue_num_str
		elif CELL_DATA.clue_type == CellTypes.ClueType.CONSECUTIVE:
			label.text = "~" + clue_num_str + "~"
		elif CELL_DATA.clue_type == CellTypes.ClueType.NON_CONSECUTIVE:
			label.text = "-" + clue_num_str + "-"
		
	
	if CELL_DATA.kind != CellTypes.CellKind.COLUMN_CLUE:
		return
		
	$Hexagons.visible = false
	
	match CELL_DATA.column_dir:
		CellTypes.ColumnDirection.DIAG_LEFT:
			var label := $Labels/LeftHint
			label.visible = true
			label.text = str(CELL_DATA.column_number)
			if CELL_DATA.clue_type == CellTypes.ClueType.CONSECUTIVE:
				label.text = "~" + label.text + "~"
			elif CELL_DATA.clue_type == CellTypes.ClueType.NON_CONSECUTIVE:
				label.text = "-" + label.text + "-"
		CellTypes.ColumnDirection.DIAG_RIGHT:
			var label := $Labels/RightHint
			label.visible = true
			label.text = str(CELL_DATA.column_number)
			if CELL_DATA.clue_type == CellTypes.ClueType.CONSECUTIVE:
				label.text = "~" + label.text + "~"
			elif CELL_DATA.clue_type == CellTypes.ClueType.NON_CONSECUTIVE:
				label.text = "-" + label.text + "-"
		CellTypes.ColumnDirection.VERTICAL:
			var label := $Labels/TopHint
			label.visible = true
			label.text = str(CELL_DATA.column_number)
			if CELL_DATA.clue_type == CellTypes.ClueType.CONSECUTIVE:
				label.text = "~" + label.text + "~"
			elif CELL_DATA.clue_type == CellTypes.ClueType.NON_CONSECUTIVE:
				label.text = "-" + label.text + "-"

func set_cell_color() -> void:
	match CELL_DATA.tile_state:
		CellTypes.TileState.BLUE_HIDDEN:
			hexagon.polygon_color = Color("ff9f01")
			inner_hexagon.polygon_color = Color("ffb129")
		CellTypes.TileState.BLUE_REVEALED:
			hexagon.polygon_color = Color("149cd8")
			inner_hexagon.polygon_color = Color("05a4eb")
		CellTypes.TileState.BLACK_HIDDEN:
			hexagon.polygon_color = Color("ff9f01")
			inner_hexagon.polygon_color = Color("ffb129")
		CellTypes.TileState.BLACK_REVEALED:
			hexagon.polygon_color = Color("2c2f31")
			inner_hexagon.polygon_color = Color("3e3e3e")

func uncover() -> void:
	print("uncovering")
	var tst := CellTypes.TileState
	var ts := CELL_DATA.tile_state

	if ts == tst.BLUE_HIDDEN:
		CELL_DATA.tile_state = tst.BLUE_REVEALED
	elif ts == tst.BLACK_HIDDEN:
		CELL_DATA.tile_state = tst.BLACK_REVEALED
	else:
		return
	update()
	
func update() -> void:
	set_cell_color()
	set_hints()
	#queue_redraw()

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("got click event: " + event.to_string())
		if CELL_DATA.tile_state == CellTypes.TileState.BLUE_HIDDEN:
			uncover()
		else:
			Autoload.increment_mistakes.emit()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		print("got click event: " + event.to_string())
		if CELL_DATA.tile_state == CellTypes.TileState.BLACK_HIDDEN:
			uncover()
		else:
			Autoload.increment_mistakes.emit()
