extends Sprite

var astar: Object = null

var MOVE_SPEED: float = 200.0

var MOVE_TIME: float = 1.9 / 60.0
var MOVE_TIME_DEV: float = 0.0 / 60.0
var move_timer: float = 0.0

var wait_timer = 0.0

var look_rot: float = 0.0

var _moving: = false
var _moving_time: = MOVE_TIME
var STUCK: float = 0.1
var previous_pos: Vector2

var move_point: Vector2
var old_move_point: Vector2
var moving_to_point: = false
var MOVE_PRECISION: float = 20.0

var target
var move_path = []

var find_path_lock: = false

enum Action {
	NONE,
	MOVE,
	WAIT,
}
var action = Action.NONE

var locked_id: int

func _ready():
	astar = get_parent().get_parent().astar
	target = global.player

func _physics_process(delta):
	#_update(delta)
	pass

func _update(delta):
	if not find_path_lock:
		find_path()
	move(delta)
	wait(delta)
	#print(name + " ", astar.check_cell(move_point))

func find_path():
	find_path_lock = true
	if target == null or action == Action.WAIT or action == Action.MOVE:
		return
	move_path = get_path_points(position, target.position)
	if move_path.size() <= 2:
		move_path.clear()
		return
	else:
		move_path.pop_front()
		move_point = move_path.front()
		if get_parent().locked_cells.has(move_point):
			move_point = old_move_point
			locked_id = astar.nearest_free_id(move_point, astar)
			astar.astar.set_point_weight_scale(locked_id, 1000)
			move_path = []
			action = Action.WAIT
			return
		old_move_point = position # move_point
		action = Action.MOVE
		move_path.pop_back()
		locked_id = astar.nearest_free_id(move_point, astar)
		#astar.astar.set_point_disabled(locked_id, true)
		astar.astar.set_point_weight_scale(locked_id, 1000)
		astar.visual_lock_cell(move_point, true)
		$locked1.global_position = self.position
		$locked1.visible = true
		$locked2.global_position = move_point
		$locked2.visible = true

func move(delta):
	if move_path.empty():
		astar.visual_lock_cell(move_point, false)
		$locked1.visible = false
		action = Action.NONE
		return
	
	var dir = -(position - move_point).normalized()
	var move_vec =  dir * MOVE_SPEED * delta
	position += move_vec
	
	if position.distance_to(move_point) < MOVE_SPEED * delta:
		position = move_point
		move_path.pop_front()
		if move_path.empty():
			$locked2.visible = false
			return
		if move_vec != Vector2.ZERO:
			#astar.astar.set_point_disabled(locked_id, false)
			astar.astar.set_point_weight_scale(locked_id, 1)
			astar.visual_lock_cell(move_point, false)
			$locked1.global_position = position
		
		astar.astar.set_point_weight_scale( astar.nearest_free_id(old_move_point, astar), 1)
		
		old_move_point = move_point
		var new_move_point = move_path.front()
		
		if get_parent().locked_cells.has(new_move_point):
			move_path = []
			action = Action.WAIT
			return
		
		move_point = new_move_point
		locked_id = astar.nearest_free_id(move_point, astar)
		#for c in get_tree().get_nodes_in_group("enemy"):
		#	move_path.clear()
		#if astar.astar.is_point_disabled(locked_id):
		#	move_path.clear()
		#	return
		#print(astar.astar.is_point_disabled(locked_id))
		#astar.astar.set_point_disabled(locked_id, true
		#astar.astar.get_point_weight_scale(locked_id)
		astar.astar.set_point_weight_scale(locked_id, 1000)
		astar.visual_lock_cell(move_point, true)
		$locked2.global_position = move_point

func backlight():
	pass

func wait(delta):
	if action != Action.WAIT:
		return
	$locked2.visible = false
	action = Action.NONE

func get_path_points(p1: Vector2, p2: Vector2) -> Array:
	var id1 = astar.nearest_free_id(p1, astar)
	if id1 < 0:
		return []
	var id2 = astar.nearest_free_id(p2, astar)
	if id2 < 0:
		return []
	return Array(astar.astar.get_point_path(id1, id2))

func _on_Timer_timeout():
	find_path_lock = false
