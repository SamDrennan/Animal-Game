@tool
extends Node3D

var beaver = preload("res://beaver.tscn")
var squirrel = preload("res://squirrel.tscn")
var wolf = preload("res://wolf.tscn")
var bear = preload("res://bear.tscn")


@onready var grid_map : GridMap = $GridMap

const RAY_LENGTH = 1000.0

var map_size = 100

var pathing

var temp_area
var selection1
var selection2

var temp_selection

var tree = []
var depot = []
var herb = []
var stone=[]
var mud= []
# split wood instances into forests which will be groups of trees


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid_map.clear()
	
	for i in range(map_size):
		for j in range(map_size/2 + 1):
			grid_map.set_cell_item(Vector3i(i,0,j), 0)
	
	print("here")
	
	#var area = $area/Coll
	#temp_area = $area
	#area.shape.size.x = map_size
	#area.shape.size.z = map_size/2
	#area.position.x = map_size/2
	#area.position.z = map_size/2

	pathing = AStarGrid2D.new()
	pathing.size = Vector2i(map_size,map_size)
	pathing.cell_size = Vector2i(1,1)
	pathing.diagonal_mode = 2
	pathing.update()
	
	selection1 = $s1
	selection2 = $s2
	
	var r
	
	#r =  Vector3i(randi_range(0,map_size - 1),1,randi_range(0,map_size/2 - 1))
	#tree.append( r )
	#grid_map.set_cell_item(r, 10)
	#pathing.set_point_solid(Vector2i(r.x, r.z))
	##print(tree)
	
	#tent
	var tentposition1=Vector3i(map_size*2/10,1,map_size*2/10)
	grid_map.set_cell_item(tentposition1, 9)
	pathing.set_point_solid(Vector2i(tentposition1.x, tentposition1.z))
	var tentposition2=Vector3i(map_size*8/10,1,map_size*3/10)
	grid_map.set_cell_item(tentposition2, 9)
	pathing.set_point_solid(Vector2i(tentposition2.x, tentposition2.z))
	
	#log
	for i in range(10):
		r = Vector3i(randi_range(0,map_size - 1),1,randi_range(0,map_size/2 - 1))
		depot.append(r)
		grid_map.set_cell_item(r, 5)#logStack
		pathing.set_point_solid(Vector2i(r.x, r.z))
	#stone
	for i in range(10):
		r = Vector3i(randi_range(0,map_size - 1),1,randi_range(0,map_size/2 - 1))
		stone.append(r)
		grid_map.set_cell_item(r, 2)#stone
		pathing.set_point_solid(Vector2i(r.x, r.z))
	
	
	#herb
	for i in range(10):
		r = Vector3i(randi_range(0,map_size - 1),1,randi_range(0,map_size/2 - 1))
		herb.append(r)
		grid_map.set_cell_item(r, 7)#herb
		pathing.set_point_solid(Vector2i(r.x, r.z))
	
	#mud
	for i in range(10):
		r = Vector3i(randi_range(0,map_size - 1),1,randi_range(0,map_size/2 - 1))
		mud.append(r)
		grid_map.set_cell_item(r, 6)#mud
		pathing.set_point_solid(Vector2i(r.x, r.z))
		
	#mountain
	var size = 10  
	var layers = 5
	
	for layer in range(1,layers+1):  
		
		var start = layer
		var end = size - layer - 1

		for x in range(start, end + 1):
			for z in range(start, end + 1):
				var position1 = Vector3i(x+map_size*6/10, layer, z+map_size*0/10)
				var position2 = Vector3i(x+map_size*5/10, layer, z+map_size*1/10)
				var position3 = Vector3i(x+map_size*4/10, layer, z+map_size*3/10)
				var position4 = Vector3i(x+map_size*3/10, layer, z+map_size*4/10)


				grid_map.set_cell_item(position1, 1,1)
				grid_map.set_cell_item(position2, 1,1)  
				grid_map.set_cell_item(position3, 1,1)
				grid_map.set_cell_item(position4, 1,1)  
				if layer == 1:
					pathing.set_point_solid(Vector2i(position1.x, position1.z))
					pathing.set_point_solid(Vector2i(position2.x, position1.z))
					pathing.set_point_solid(Vector2i(position3.x, position1.z))
					pathing.set_point_solid(Vector2i(position4.x, position1.z))
	
	#forest
	var forest_size=25
	
	for i in range(25):
		var treeposition1 = Vector3i(randi_range(map_size*2.5/10,map_size*2.5/10+forest_size),1,
		randi_range(map_size*0/10,map_size*0/10+forest_size))
		tree.append(treeposition1)
		grid_map.set_cell_item(treeposition1, 10)#tree
		pathing.set_point_solid(Vector2i(treeposition1.x, treeposition1.z))
		var treeposition2 = Vector3i(randi_range(map_size*5/10,map_size*5/10+forest_size),1,
		randi_range(map_size*2.5/10,map_size*2.5/10+forest_size))
		tree.append(treeposition2)
		grid_map.set_cell_item(treeposition2, 10)#tree
		pathing.set_point_solid(Vector2i(treeposition2.x, treeposition2.z))
	
	#quarry
	var quarry_size =20
	var mud_stone_num=5
	for i in range(mud_stone_num):
		var mud_position1=Vector3i(randi_range(map_size*2/10,map_size*2/10+quarry_size),1,
		randi_range(map_size*2.5/10,map_size*2.5/10+quarry_size))
		mud.append(mud_position1)
		grid_map.set_cell_item(mud_position1, 6)#mud
		pathing.set_point_solid(Vector2i(mud_position1.x, mud_position1.z))
		var mud_position2=Vector3i(randi_range(map_size*6/10,map_size*6/10+quarry_size),1,
		randi_range(map_size*1/10,map_size*1/10+quarry_size))
		mud.append(mud_position2)
		grid_map.set_cell_item(mud_position2, 6)#mud
		pathing.set_point_solid(Vector2i(mud_position2.x, mud_position2.z))
		
		var stone_position1=Vector3i(randi_range(map_size*2/10,map_size*2/10+quarry_size),1,
		randi_range(map_size*2.5/10,map_size*2.5/10+quarry_size))
		stone.append(stone_position1)
		grid_map.set_cell_item(stone_position1, 7)#mud
		pathing.set_point_solid(Vector2i(stone_position1.x, stone_position1.z))
		var stone_position2=Vector3i(randi_range(map_size*6/10,map_size*6/10+quarry_size),1,
		randi_range(map_size*1/10,map_size*1/10+quarry_size))
		stone.append(stone_position2)
		grid_map.set_cell_item(stone_position2, 7)#mud
		pathing.set_point_solid(Vector2i(stone_position2.x, stone_position2.z))
	
	
	var a_beaver : Dynamic_Unit = beaver.instantiate()
	a_beaver.position = Vector3(2,1,4)
	a_beaver.unitID = 1
	a_beaver.set_team(2)
	add_child(a_beaver)
	
	var a_squirrel : Dynamic_Unit = squirrel.instantiate()
	a_squirrel.position = Vector3(4,1,4)
	a_squirrel.unitID = 2
	a_squirrel.set_team(2)
	add_child(a_squirrel)
	
	var a_wolf : Dynamic_Unit = wolf.instantiate()
	a_wolf.position = Vector3(1,1,1)
	a_wolf.unitID = 3
	a_wolf.set_team(1)
	add_child(a_wolf)
	
	var a_bear : Dynamic_Unit = bear.instantiate()
	a_bear.position = Vector3(4,1,2)
	a_bear.unitID = 4
	a_bear.set_team(1)
	add_child(a_bear)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
		
	
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
		#selection2.position = selection1.position
		#var new_pos = result["position"]
		#selection1.position = Vector3( ceil(new_pos.x + .5) - .5, 1, ceil(new_pos.z + .5) - .5)


		#var unit_script : Script = result["collider"].get_parent().get_script().get_base_script()
		var unit_script = result["collider"].get_script()
		
		if (event.button_index == 1):
			if (unit_script != null):
				print(result["collider"].get_script().get_global_name())
				if (unit_script.get_global_name() == "Dynamic_Unit"):
					if (temp_selection != null):
						temp_selection.selected = false
					temp_selection = result["collider"]
					temp_selection.selected = true
			else:
				if (temp_selection != null):
					temp_selection.selected = false
				temp_selection = null
			
			
		#if (event.button_index == 1):
			#if (unit_script != null):
				#if (unit_script.get_global_name() == "Unit"):
					#temp_selection = result["collider"].get_parent()
			#else:
				#temp_selection = null
		
		if (event.button_index == 2):
			if (temp_selection != null):
				if (temp_selection.get_script().get_global_name() == "Dynamic_Unit"):
					if (unit_script != null):
						if (unit_script.get_base_script().get_global_name() == "Unit"):
							temp_selection.attacking = result["collider"]
					else:
						temp_selection.attacking = null
				
					print(pathing.get_id_path(Vector2i(temp_selection.position.x, temp_selection.position.z), Vector2i(result["position"].x, result["position"].z)))
					temp_selection.set_path( pathing.get_id_path(Vector2(temp_selection.position.x - .5, temp_selection.position.z - .5), Vector2(result["position"].x, result["position"].z)) )
					#temp_selection.destination = Vector3(result["position"].x, 1, result["position"].z)

	else:
		if (event.button_index == 1):
			if (temp_selection != null):
				temp_selection.selected = false
			temp_selection = null

func attack_action():
	if (temp_selection.get_script().get_global_name() == "Dynamic_Unit"):
		temp_selection.attack()
