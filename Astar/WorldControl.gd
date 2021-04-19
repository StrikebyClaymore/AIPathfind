extends Node

var enemy_tscn: PackedScene = preload("res://Astar/objects/Enemy.tscn")
var floor_tscn: PackedScene = preload("res://Astar/objects/Floor.tscn")
var wall_tscn: PackedScene = preload("res://Astar/objects/Wall.tscn")

onready var enemies_container: = get_parent().get_node("Enemies")

var start: = false
var player
var target

func _ready():
	pass

func _input(ev):
	if ev is InputEventMouseButton and ev.is_pressed():
		var pos = get_parent().astar.tile_to_position(get_parent().astar.position_to_tile(get_parent().get_global_mouse_position()))
		if ev.button_index == 1:
			spawn_enemy(pos)
		elif ev.button_index == 2:
			if start:
				set_target_pos(pos)
			else:
				create_target(pos)
		else:
			build_wall(pos)

func create_target(pos:Vector2):
	start = true
	var sprite: = Sprite.new()
	sprite.texture = load("res://images/human.png")
	sprite.position = pos
	player = sprite
	global.player = sprite
	get_parent().add_child(sprite)

func set_target_pos(pos:Vector2):
	player.position = pos
	#for e in get_tree().get_nodes_in_group("enemy"):
	#	e.action = e.Action.NONE

func spawn_enemy(pos:Vector2):
	var e = enemy_tscn.instance()
	e.position = pos
	enemies_container.add_child(e)

func build_wall(pos:Vector2):
	var astar = get_parent().get_node("Astar")
	var locked_id = astar.nearest_free_id(pos, astar)
	astar.astar.set_point_weight_scale(locked_id, 1000)
	pass

