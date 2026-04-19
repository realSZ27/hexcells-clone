extends Node2D

var CELL_DATA: CellData

@onready var hexagon := $Hexagons/Hexagon
@onready var inner_hexagon := $Hexagons/InnerHexagon
@onready var radial := $Helpers/RadialHelp/BigRadius
@onready var radial_outline := $Helpers/RadialHelp/BigRadius/Line2D

var _is_hovered := false

var _radial_expanded := false
var _radial_tween: Tween
var _pulse_tween: Tween

var _base_position: Vector2
var _shake_time := 0.0
var _shaking := false

const SHAKE_DURATION := 0.2
const SHAKE_AMPLITUDE := 2.0
const SHAKE_SPEED := 50.0

const EXPAND_DURATION := 0.3

func _ready() -> void:
	if CELL_DATA == null:
		return
		
	_base_position = position
	radial_outline.points = radial.polygon
	
	update()

func _process(delta: float) -> void:
	_animate_shake(delta)

func toggle_radial() -> void:
	if _radial_tween:
		_radial_tween.kill()

	_radial_tween = create_tween()

	if _radial_expanded:
		# Collapse
		_radial_tween.tween_property(radial, "scale", Vector2.ZERO, 0.25)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_IN)

		_radial_tween.tween_callback(func() -> void:
			radial.visible = false
			_stop_radial_pulse()
		)
	else:
		# Expand
		radial.scale = Vector2.ZERO
		radial.visible = true
		
		_start_radial_pulse()

		_radial_tween.tween_property(radial, "scale", Vector2.ONE, 0.3)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_OUT)

	_radial_expanded = !_radial_expanded
	
func _start_radial_pulse() -> void:
	if _pulse_tween:
		_pulse_tween.kill()

	_pulse_tween = create_tween()
	_pulse_tween.set_loops() # infinite loop

	radial.modulate.a = 0.25

	_pulse_tween.tween_property(radial, "modulate:a", 0.75, 0.6)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

	_pulse_tween.tween_property(radial, "modulate:a", 0.5, 0.6)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
		
func _stop_radial_pulse() -> void:
	if _pulse_tween:
		_pulse_tween.kill()
		
func _animate_shake(delta: float) -> void:
	if not _shaking:
		return

	_shake_time += delta

	if _shake_time >= SHAKE_DURATION:
		_shaking = false
		position = _base_position
		_shake_time = 0.0
		return

	var t := _shake_time * SHAKE_SPEED
	
	var strength := 1.0 - (_shake_time / SHAKE_DURATION)

	var offset := Vector2(
		sin(t) * SHAKE_AMPLITUDE,
		cos(t * 1.7) * SHAKE_AMPLITUDE
	) * strength

	position = _base_position + offset

# ========================
# UPDATE PIPELINE
# ========================

func update() -> void:
	set_cell_color()
	set_hints()


# ========================
# HINTS
# ========================

func set_hints() -> void:
	match CELL_DATA.kind:
		CellTypes.CellKind.TILE:
			_set_tile_hints()
		CellTypes.CellKind.COLUMN_CLUE:
			_set_column_hints()


func _set_tile_hints() -> void:
	var label := $Labels/CenterLabel

	# Reset
	label.visible = false

	if CELL_DATA.clue_type == CellTypes.ClueType.NONE:
		if CELL_DATA.is_black() and CELL_DATA.is_revealed():
			label.text = "?"
			label.visible = true
		return

	if CELL_DATA.is_hidden():
		return

	label.visible = true
	label.text = format_clue_text(str(CELL_DATA.clue_number))


func _set_column_hints() -> void:
	$Hexagons.visible = false

	var label_map := {
		CellTypes.ColumnDirection.DIAG_LEFT: $Labels/LeftHint,
		CellTypes.ColumnDirection.DIAG_RIGHT: $Labels/RightHint,
		CellTypes.ColumnDirection.VERTICAL: $Labels/TopHint
	}

	var label: Label = label_map.get(CELL_DATA.column_dir)
	if label == null:
		return

	label.visible = true
	label.text = format_clue_text(str(CELL_DATA.column_number))


func format_clue_text(value: String) -> String:
	match CELL_DATA.clue_type:
		CellTypes.ClueType.NORMAL:
			return value
		CellTypes.ClueType.CONSECUTIVE:
			return "{" + value + "}"
		CellTypes.ClueType.NON_CONSECUTIVE:
			return "-" + value + "-"
		_:
			return value


# ========================
# COLORS
# ========================

func set_cell_color() -> void:
	match CELL_DATA.tile_state:
		CellTypes.TileState.BLUE_HIDDEN, CellTypes.TileState.BLACK_HIDDEN:
			_set_colors("ff9f01", "ffb129")
		CellTypes.TileState.BLUE_REVEALED:
			_set_colors("149cd8", "05a4eb")
		CellTypes.TileState.BLACK_REVEALED:
			_set_colors("2c2f31", "3e3e3e")


func _set_colors(outer: String, inner: String) -> void:
	var base_outer := Color(outer)
	var base_inner := Color(inner)

	if _is_hovered:
		base_outer = base_outer.darkened(0.2)
		base_inner = base_inner.darkened(0.2)

	hexagon.polygon_color = base_outer
	inner_hexagon.polygon_color = base_inner


# ========================
# GAMEPLAY
# ========================

func uncover() -> void:
	var new_state := CELL_DATA.get_revealed_state()
	if new_state == CELL_DATA.tile_state:
		return
	
	CELL_DATA.tile_state = new_state
	update()


# ========================
# INPUT
# ========================

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is not InputEventMouseButton or !event.pressed:
		return

	var e := event as InputEventMouseButton

	match CELL_DATA.kind:
		CellTypes.CellKind.TILE:
			_handle_tile_click(e)
		CellTypes.CellKind.COLUMN_CLUE:
			_handle_column_click(e)


# ---- TILE INPUT ----

func _handle_tile_click(e: InputEventMouseButton) -> void:
	print("got click event: " + e.to_string())

	match e.button_index:
		MOUSE_BUTTON_LEFT:
			_handle_tile_left_click()
		MOUSE_BUTTON_RIGHT:
			_handle_tile_right_click()


func _handle_tile_left_click() -> void:
	match CELL_DATA.tile_state:
		CellTypes.TileState.BLUE_HIDDEN:
			uncover()
		CellTypes.TileState.BLACK_HIDDEN:
			Autoload.increment_mistakes.emit()
		_:
			if CELL_DATA.is_blue() and CELL_DATA.clue_type == CellTypes.ClueType.NORMAL:
				toggle_radial()


func _handle_tile_right_click() -> void:
	match CELL_DATA.tile_state:
		CellTypes.TileState.BLACK_HIDDEN:
			uncover()
		CellTypes.TileState.BLUE_HIDDEN:
			Autoload.increment_mistakes.emit()


# ---- COLUMN INPUT ----

func _handle_column_click(e: InputEventMouseButton) -> void:
	if e.button_index != MOUSE_BUTTON_LEFT:
		return

	print("got click event for column clue: " + e.to_string())

	var helper_map := {
		CellTypes.ColumnDirection.DIAG_RIGHT: $Helpers/LinearHelp/LeftHelper,
		CellTypes.ColumnDirection.DIAG_LEFT: $Helpers/LinearHelp/RightHelper,
		CellTypes.ColumnDirection.VERTICAL: $Helpers/LinearHelp/VertHelper
	}

	var helper: Node2D = helper_map.get(CELL_DATA.column_dir)
	if helper == null:
		return

	# yeah… still cursed, but isolated now
	helper.size = Vector2(6.62, 2010.976)
	swap_visibility(helper)


# ========================
# UTILS
# ========================

func swap_visibility(node: Node) -> void:
	node.visible = !node.visible


func _on_mouse_entered() -> void:
	if CELL_DATA.is_hidden():
		_is_hovered = true
		_shaking = true
		update()


func _on_mouse_exited() -> void:
	_is_hovered = false
	update()
