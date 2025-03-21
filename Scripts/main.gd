@tool
extends Node3D

var beaver = preload("res://beaver.tscn")
var squirrel = preload("res://squirrel.tscn")
var wolf = preload("res://wolf.tscn")
var bear = preload("res://bear.tscn")


@onready var grid_map : GridMap = $GridMap

const RAY_LENGTH = 1000.0

var map_size = 10

var temp_area
var selection1
var selection2

var temp_selection

var tree
var depot

# split wood instances into forests which will be groups of trees


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid_map.clear()
	
	for i in range(map_size):
		for j in range(map_size):
			grid_map.set_cell_item(Vector3i(i,0,j), 0)
	
	print("here")
	
	var area = $area/Coll
	temp_area = $area
	area.scale.x = map_size
	area.scale.z = map_size
	area.position.x = map_size/2
	area.position.z = map_size/2
	
	selection1 = $s1
	selection2 = $s2
	
	tree = Vector3i(randi_range(0,map_size - 1),1,randi_range(0,map_size - 1))
	grid_map.set_cell_item(tree, 100)
	print(tree)
	depot = Vector3i(randi_range(0,map_size - 1),1,randi_range(0,map_size - 1))
	grid_map.set_cell_item(depot, 73)
	
	var a_beaver : Dynamic_Unit = beaver.instantiate()
	a_beaver.position = Vector3(2,2,4)
	a_beaver.unitID = 1
	add_child(a_beaver)
	
	var a_squirrel : Dynamic_Unit = squirrel.instantiate()
	a_squirrel.position = Vector3(4,2,4)
	a_squirrel.unitID = 2
	add_child(a_squirrel)
	
	var a_wolf : Dynamic_Unit = wolf.instantiate()
	a_wolf.position = Vector3(1,2,1)
	a_wolf.unitID = 3
	add_child(a_wolf)
	
	var a_bear : Dynamic_Unit = bear.instantiate()
	a_bear.position = Vector3(4,2,2)
	a_bear.unitID = 4
	add_child(a_bear)
	
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		if Input.is_action_pressed("select_cat"):
			temp_selection = $a_Cat
		
	
func _input(event):
	if event is InputEventMouseButton and event.pressed and (event.button_index == 1 or event.button_index == 2):
		select_node(event)

func select_node(event):
	var camera = $CameraPivot/Camera2
	var from = camera.project_ray_origin(event.position)
	var to = from + camera.project_ray_normal(event.position) * 1000.0
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	print(result)
	
	if result.size() > 0:
		selection2.position = selection1.position
		var new_pos = result["position"]
		selection1.position = Vector3( ceil(new_pos.x + .5) - .5, 1, ceil(new_pos.z + .5) - .5)


		var unit_script : Script = result["collider"].get_parent().get_script().get_base_script()
		
		if (event.button_index == 1):
			if (unit_script != null):
				if (unit_script.get_global_name() == "Unit"):
					temp_selection = result["collider"].get_parent()
			else:
				temp_selection = null
		
		if (event.button_index == 2):
			if (temp_selection != null):
				if (temp_selection.get_script().get_global_name() == "Dynamic_Unit"):
					if (unit_script != null):
						if (unit_script.get_global_name() == "Unit"):
							temp_selection.attacking = result["collider"].get_parent()
					else:
						temp_selection.attacking = null
				
					temp_selection.destination = Vector3(result["position"].x, 1, result["position"].z)

	else:
		if (event.button_index == 1):
			temp_selection = null
