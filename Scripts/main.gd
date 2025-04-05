
extends Node3D

var beaver = preload("res://beaver.tscn")
var squirrel = preload("res://squirrel.tscn")
var wolf = preload("res://wolf.tscn")
var bear = preload("res://bear.tscn")
var tent = preload("res://tent.tscn")

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

var player_tribe
var player_tent_position
# split wood instances into forests which will be groups of trees


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid_map.clear()
	
	for i in range(map_size):
		for j in range(map_size/2 + 1):
			grid_map.set_cell_item(Vector3i(i,0,j), 0)

	pathing = AStarGrid2D.new()
	pathing.size = Vector2i(map_size,map_size/2 + 1)
	pathing.cell_size = Vector2i(1,1)
	pathing.diagonal_mode = 2
	pathing.update()
	
	var r
	
	#tent
	player_tent_position=Vector3i(map_size*2/10,1,map_size*2/10)
	grid_map.set_cell_item(player_tent_position, 9)
	pathing.set_point_solid(Vector2i(player_tent_position.x, player_tent_position.z))
	
	player_tent_position = Vector3(player_tent_position.x + 0.5,player_tent_position.y,player_tent_position.z + 0.5)
	
	var a_tent : Static_Unit = tent.instantiate()
	a_tent.set_static_position(Vector3(player_tent_position.x,player_tent_position.y,player_tent_position.z))
	a_tent.unitID = 1
	a_tent.set_team(1)
	add_child(a_tent)
	
	var enemy_tent_position=Vector3i(map_size*8/10,1,map_size*3/10)
	grid_map.set_cell_item(enemy_tent_position, 9)
	pathing.set_point_solid(Vector2i(enemy_tent_position.x, enemy_tent_position.z))
	
	var a_tent_2 : Static_Unit = tent.instantiate()
	a_tent_2.set_static_position(Vector3(enemy_tent_position.x + 0.5,enemy_tent_position.y,enemy_tent_position.z + 0.5))
	a_tent_2.unitID = 1
	a_tent_2.set_team(2)
	add_child(a_tent_2)
	
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
	
	
	#tribe infor mation set up
	player_tribe=Tribe.new()
	$"Tribe info".setup(player_tribe)
	player_tribe.add_resources([30,30,30,30,30])
	
	
	var a_beaver : Dynamic_Unit = beaver.instantiate()
	a_beaver.position = Vector3(2.5,1,4.5)
	a_beaver.unitID = 1
	a_beaver.set_team(1)
	add_child(a_beaver)
	player_tribe.units.append(a_beaver)
	#print(tribe_info.units)
	
	var a_squirrel : Dynamic_Unit = squirrel.instantiate()
	a_squirrel.position = Vector3(4.5,1,4.5)
	a_squirrel.unitID = 2
	a_squirrel.set_team(2)
	add_child(a_squirrel)
	
	var a_wolf : Dynamic_Unit = wolf.instantiate()
	a_wolf.position = Vector3(1.5,1,1.5)
	a_wolf.unitID = 3
	a_wolf.set_team(1)
	add_child(a_wolf)
	
	var a_bear : Dynamic_Unit = bear.instantiate()
	a_bear.position = Vector3(4.5,1,2.5)
	a_bear.unitID = 4
	a_bear.set_team(1)
	add_child(a_bear)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_released("ability_1"):
		if (temp_selection != null):
			if (temp_selection.get_script().get_global_name() == "Static_Unit"):
				temp_selection.spawn1()
	if Input.is_action_just_released("ability_2"):
		if (temp_selection != null):
			if (temp_selection.get_script().get_global_name() == "Static_Unit"):
				temp_selection.spawn2()
		
	
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
		var unit_script = result["collider"].get_script()
		
		if (event.button_index == 1):
			if (unit_script != null):
				print(result["collider"].get_script().get_global_name())
				if (unit_script.get_base_script().get_global_name() == "Unit"):
					if (temp_selection != null):
						temp_selection.selected = false
					temp_selection = result["collider"]
					temp_selection.selected = true
			else:
				if (temp_selection != null):
					temp_selection.selected = false
				temp_selection = null
		
		if (event.button_index == 2):
			if (temp_selection != null):
				if (temp_selection.get_script().get_global_name() == "Dynamic_Unit"):
					var is_unit = false
					var clicked_resource = false
					temp_selection.harvesting = 0
					match grid_map.get_cell_item(result["position"]):
						2:
							temp_selection.harvesting = 5
							clicked_resource = true
						5:
							temp_selection.harvesting = 3
							clicked_resource = true
						6:
							temp_selection.harvesting = 4
							clicked_resource = true
						7:
							temp_selection.harvesting = 1
							clicked_resource = true
						10:
							temp_selection.harvesting = 2
							clicked_resource = true
					if (clicked_resource):
						temp_selection.harvest_location = result["position"]
						
						
					if (unit_script != null):
						if (unit_script.get_base_script().get_global_name() == "Unit"):
							temp_selection.attacking = result["collider"]
							
							is_unit = true
					else:
						temp_selection.attacking = null
						
					if (is_unit):
						temp_selection.set_path( get_unit_path(temp_selection.position, result["collider"].position, is_unit) )
					else:
						temp_selection.set_path( get_unit_path(temp_selection.position, result["position"], is_unit) )

	else:
		if (event.button_index == 1):
			if (temp_selection != null):
				temp_selection.selected = false
			temp_selection = null

func get_unit_path(start_pos: Vector3, end_pos: Vector3, is_unit: bool) -> Array:
	var dest_x = end_pos.x
	var dest_z = end_pos.z
	
	if (is_unit):
		var x_comp = end_pos.x - start_pos.x
		var z_comp = end_pos.z - start_pos.z
		
		if (x_comp > 0.5):
			dest_x = end_pos.x - 1
		elif (x_comp < -0.5):
			dest_x = end_pos.x + 1
		if (z_comp > 0.5):
			dest_z = end_pos.z - 1
		elif (z_comp < -0.5):
			dest_z = end_pos.z + 1

	return pathing.get_id_path(Vector2(start_pos.x - .5, start_pos.z - .5), Vector2(dest_x, dest_z))
	
