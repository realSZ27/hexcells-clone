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
	if CELL_DATA.clue_number != -1:
		$Labels/CenterLabel.visible = true
		$Labels/CenterLabel.text = str(CELL_DATA.clue_number)
	
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
	if CELL_DATA.kind == CellTypes.CellKind.COLUMN_CLUE:
		pass

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
