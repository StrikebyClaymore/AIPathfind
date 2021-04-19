extends Node2D

var e_idx = 0 

func _ready():
	pass

var lock = false
var locked_cells = []

func _physics_process(delta):
	enemies_update_process(delta)
	pass

func enemies_update_process(delta):
	if lock: return
	for i in range(e_idx, get_child_count()):
		var e = get_children()[i]
		locked_cells.erase(e.move_point)
		e._update(delta)
		locked_cells.append(e.move_point)
		e_idx = i + 1
		if e_idx == get_child_count():
			e_idx = 0
	#get_parent().light_cells()

func _on_Timer_timeout():
	lock = false



		#yield(get_tree().create_timer(.1), "timeout")
		#return
		
		#get_parent().get_node("Timer").start()
		#lock = true
		#return
