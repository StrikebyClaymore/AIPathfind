extends Node2D

onready var w_control: = $WorldControl
onready var astar: = $Astar
onready var walls: = $Walls

func _ready():
	pass

func light_cells() -> void:
	var a: AStar2D = $Astar.astar
	for p in a.get_points():
		#prints(a.get_point_position(p), a.get_point_weight_scale(p))
		if a.get_point_weight_scale(p) != 1:
			$Floor.set_cellv($Astar.position_to_tile(a.get_point_position(p)), 1)
		else:
			$Floor.set_cellv($Astar.position_to_tile(a.get_point_position(p)), 0)
	pass
