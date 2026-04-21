extends Node2D

@onready var GRID := $Grid
@onready var MISTAKES_NUM := $UI/VBoxContainer/MarginContainer2/MarginContainer/VBoxContainer2/Number
@onready var REMAINING_NUM := $UI/VBoxContainer/MarginContainer/MarginContainer/VBoxContainer/Number

var cell_scene := preload("res://cell.tscn")

var map: Map

var mistakes_count := 0
var remaining := 0

# visual config
const HEX_SIZE := 20.0

func _ready() -> void:
	map = Map.from_file("res://levels/rougelike.hexcells")
	
	Autoload.increment_mistakes.connect(func() -> void:
		mistakes_count += 1
		MISTAKES_NUM.text = str(mistakes_count)
	)
	queue_redraw()
	
func _process(_delta: float) -> void:
	remaining = 0
	
	map.for_each_cell(func(cell: CellData, _col: int, _row: int) -> void: 
		if cell.is_blue() and cell.is_hidden():
			remaining += 1
	)
	
	REMAINING_NUM.text = str(remaining)

func _draw() -> void:
	map.for_each_cell(draw_cell)

func draw_cell(cell: CellData, col: int, row: int) -> void:
	if cell.kind == CellTypes.CellKind.EMPTY:
		print("nothing at " + str(col) + " " + str(row))
		return

	var new_cell := cell_scene.instantiate()
	new_cell.position = to_global(GRID.map_to_local(Vector2i(col, row)))
	new_cell.CELL_DATA = cell
	GRID.add_child(new_cell)
