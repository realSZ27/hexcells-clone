extends Node2D

@onready var GRID := $Grid

var cell_scene := preload("res://cell.tscn")

var map: Map

var mistakes_count := 0
var remaining := 0

# visual config
const HEX_SIZE := 20.0

func _ready() -> void:
	map = Map.from_file("res://levels/thetrial.hexcells")
	
	Autoload.increment_mistakes.connect(_increment_mistakes)
	queue_redraw()
	
func _process(_delta: float) -> void:
	map.for_each_cell(count_blue_cells)
	
func count_blue_cells(cell: CellData, _col: int, _row: int) -> void: 
	if cell.is_blue():
		remaining += 1
	

func _draw() -> void:
	map.for_each_cell(draw_cell)

func draw_cell(cell: CellData, col: int, row: int) -> void:
	if cell.kind == CellTypes.CellKind.EMPTY:
		print("nothing at " + str(col) + " " + str(row))
		return

	var new_cell := cell_scene.instantiate()
	new_cell.position = to_global(GRID.map_to_local(Vector2i(col, row)))
	new_cell.CELL_DATA = cell
	add_child(new_cell)

func _increment_mistakes() -> void:
	mistakes_count += 1
	$UI/VBoxContainer/Mistakes.text = str(mistakes_count)
