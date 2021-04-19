extends Node

onready var astar: Reference = AStar2D.new()

onready var walls = get_parent().get_node("Walls")
onready var _floor = get_parent().get_node("Floor")

onready var width = OS.window_size.x
onready var height = OS.window_size.y
onready var cell_width = walls.cell_size.x
onready var cell_height = walls.cell_size.y 
onready var width_in_cells: = int(width / cell_width)
onready var height_in_cells: = int(height / cell_height)

func _ready():
	init_astar()
	#astar.set_point_disabled(33, true)
	var id1 = nearest_free_id(Vector2(368, 400), astar)
	var id2 = nearest_free_id(Vector2(560, 240), astar)
	print(astar.get_point_path(id1, id2))
	pass

func visual_lock_cell(pos, lock = false):
	pos = _floor.world_to_map(pos)
	if lock:
		_floor.set_cellv(pos, 1)
		pass
	else:
		_floor.set_cellv(pos, 0)
	pass

func check_cell(pos):
	pos = _floor.world_to_map(pos)
	var result = _floor.get_cellv(pos)
	return result

func tile_to_position(t: Vector2) -> Vector2:
	return Vector2((t.x + 0.5) * cell_width, (t.y + 0.5) * cell_height)

func position_to_tile(p: Vector2) -> Vector2:
	return Vector2(int(p.x / cell_width), int(p.y / cell_height))

func _tile_to_id(x, y):
	return x + y * width_in_cells

func tile_to_id(t: Vector2):
	return _tile_to_id(t.x, t.y)

func position_to_id(p: Vector2):
	return tile_to_id(position_to_tile(p))

func get_path_points(p1: Vector2, p2: Vector2) -> Array:
	return Array(astar.get_point_path(position_to_id(p1), position_to_id(p2)))

func nearest_free_id(p: Vector2, astar_: Reference = astar) -> int:
	if astar_ == null:
		astar_ = astar
	var id_ = position_to_id(p)
	if astar_.has_point(id_) and !astar_.is_point_disabled(id_):
		return id_
	var t1 = position_to_tile(p)
	var t2 = position_to_tile(p)
	for x_ in range(t1.x, t2.x + 1):
		for y_ in range(t1.y, t2.y + 1):
			id_ = _tile_to_id(x_, y_)
			if astar_.has_point(id_) and !astar_.is_point_disabled(id_):
				return id_
	return -1

func init_astar():
	var Y = height_in_cells - 1
	var X = width_in_cells - 1
	for y in range(Y, -1, -1):
		for x in range(X, -1, -1):
			if walls.get_cell(x, y) != -1:
				continue
			var ti = _tile_to_id(x, y)
			astar.add_point(ti, tile_to_position(Vector2(x, y)))
			if y != Y:
				if walls.get_cell(x, y + 1) == -1:
					astar.connect_points(ti, _tile_to_id(x, (y + 1)), true)
				if x != 0:
					if walls.get_cell(x - 1, y + 1) == -1:
						astar.connect_points(ti, _tile_to_id(x - 1, y + 1), true)
				if x != X:
					if walls.get_cell(x + 1, y + 1) == -1:
						astar.connect_points(ti, _tile_to_id(x + 1, y + 1), true)
			if x != X:
				if walls.get_cell(x + 1, y) == -1:
					astar.connect_points(ti, _tile_to_id(x + 1, y), true)

func copy_astar() -> Object:
	return astar
