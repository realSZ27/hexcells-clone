extends Node2D

# ========================
# 🖱️ Drag / Touch State
# ========================
var dragging: bool = false
var last_pointer_pos: Vector2 = Vector2.ZERO

var zoom: float = 1.0
const MIN_ZOOM: float = 0.5
const MAX_ZOOM: float = 3.0
const ZOOM_STEP: float = 0.1
const DRAG_THRESHOLD: float = 5.0

var touches: Dictionary[int, Vector2] = {}
var last_pinch_distance: float = 0.0
var drag_start_pos: Vector2 = Vector2.ZERO
var is_dragging_real: bool = false

# ========================
# 🧊 Inertia
# ========================
var velocity: Vector2 = Vector2.ZERO
const INERTIA_DAMP: float = 8.0   # higher = faster slowdown

func _ready() -> void:
	scale = Vector2.ONE * zoom


func _input(event: InputEvent) -> void:

	# ========================
	# 🖱️ Mouse (UNCHANGED)
	# ========================
	if event is InputEventMouseButton:
		var e := event as InputEventMouseButton

		if e.button_index == MOUSE_BUTTON_LEFT:
			if e.pressed:
				dragging = true
				is_dragging_real = false
				drag_start_pos = e.position
				last_pointer_pos = e.position
			else:
				call_deferred("_end_drag")

		elif e.button_index == MOUSE_BUTTON_WHEEL_UP and e.pressed:
			zoom_at_point(1.0 + ZOOM_STEP, e.position)

		elif e.button_index == MOUSE_BUTTON_WHEEL_DOWN and e.pressed:
			zoom_at_point(1.0 - ZOOM_STEP, e.position)

	elif event is InputEventMouseMotion:
		if dragging:
			var e := event as InputEventMouseMotion
			
			if not is_dragging_real:
				if e.position.distance_to(drag_start_pos) > DRAG_THRESHOLD:
					is_dragging_real = true

			if is_dragging_real:
				position += e.relative


	# ========================
	# 📱 Touch Input
	# ========================
	elif event is InputEventScreenTouch:
		var e := event as InputEventScreenTouch

		if e.pressed:
			touches[e.index] = e.position
			drag_start_pos = e.position
			velocity = Vector2.ZERO
		else:
			touches.erase(e.index)

		if touches.size() < 2:
			last_pinch_distance = 0.0
			is_dragging_real = false


	elif event is InputEventScreenDrag:
		var e := event as InputEventScreenDrag
		touches[e.index] = e.position

		if touches.size() == 1:
			# Single finger drag (scaled properly)
			if not is_dragging_real:
				if e.position.distance_to(drag_start_pos) > DRAG_THRESHOLD:
					is_dragging_real = true

			if is_dragging_real:
				var delta := e.relative / zoom
				position += delta

				# velocity in pixels/sec
				velocity = delta / get_process_delta_time()

		elif touches.size() == 2:
			handle_pinch_zoom()


# ========================
# 🔍 Zoom Logic
# ========================
func zoom_at_point(factor: float, screen_point: Vector2) -> void:
	var old_zoom: float = zoom
	zoom = clamp(zoom * factor, MIN_ZOOM, MAX_ZOOM)

	var actual_factor: float = zoom / old_zoom
	scale = Vector2.ONE * zoom

	# keep your original behavior for mouse,
	# but this now works correctly for touch too
	position = screen_point + (position - screen_point) * actual_factor


func handle_pinch_zoom() -> void:
	var points := touches.values()

	var p1: Vector2 = points[0]
	var p2: Vector2 = points[1]

	var current_distance: float = p1.distance_to(p2)

	if last_pinch_distance == 0.0:
		last_pinch_distance = current_distance
		return

	var raw_factor: float = current_distance / last_pinch_distance

	# smooth it slightly (prevents jitter)
	var factor: float = lerp(1.0, raw_factor, 0.2)

	var center: Vector2 = (p1 + p2) * 0.5
	zoom_at_point(factor, center)

	last_pinch_distance = current_distance


# ========================
# 🧊 Inertia (delta-based)
# ========================
func _process(delta: float) -> void:
	if not dragging and touches.size() == 0:
		if velocity.length() > 1.0:
			position += velocity * delta
			velocity = velocity.lerp(Vector2.ZERO, INERTIA_DAMP * delta)
		else:
			velocity = Vector2.ZERO


# ========================
# 🧹 Helpers
# ========================
func should_block_click(release_pos: Vector2) -> bool:
	if not dragging:
		return false
	
	return release_pos.distance_to(drag_start_pos) > DRAG_THRESHOLD


func _end_drag() -> void:
	dragging = false
	is_dragging_real = false
	drag_start_pos = Vector2.ZERO
