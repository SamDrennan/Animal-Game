extends Unit

class_name Static_Unit

var beaver = preload("res://beaver.tscn")
var squirrel = preload("res://squirrel.tscn")
var wolf = preload("res://wolf.tscn")
var bear = preload("res://bear.tscn")

var unitID: int # 1 = tent, 2 = den
var spawn_position: Vector3

# variables for AI spawning
var first_spawn: bool = true
var spawn_squirrel: float = 8
var spawn_wolf: float = 14
var spawn_bear: float = 18

func _init():
	# set super value
	super._init(100,0)

func _ready() -> void:
	
	var label = $Sprite3D/SubViewport/Panel/Label
	match unitID:
		1:
			label.text = "Tent"
		2:
			label.text = "Den"

func _process(delta: float) -> void:
	$Sprite3D/SubViewport/ProgressBar.value=health
	
	if (team == 2):
		spawn_AI(delta)
	
	if (self.health <= 0):
		var root = get_parent()
		root.get_node("GridMap").set_cell_item(self.position,-1)
		root.pathing.set_point_solid(Vector2i(self.position.x, self.position.z), false)
	
	super._process(delta)

func spawn_AI(delta: float) -> void:
	
	if (spawn_squirrel > 0):
		spawn_squirrel -= delta
	if (spawn_wolf > 0):
		spawn_wolf -= delta
	if (spawn_bear > 0):
		spawn_bear -= delta
	
	if (first_spawn):
		for i in range(0,3):
			spawn1()
		first_spawn = false
	if (spawn_squirrel <= 0):
		spawn2()
		spawn_squirrel = 8
	if (spawn_wolf <= 0):
		spawn3()
		spawn_wolf = 20
	if (spawn_bear <= 0):
		spawn4()
		spawn_bear = 30
		

func set_static_position(pos: Vector3) -> void:
	position = pos
	spawn_position = Vector3(self.position.x,self.position.y,self.position.z + 1)

func spawn1() -> void:
	if (unitID == 1):
		var a_beaver : Dynamic_Unit = beaver.instantiate()
		a_beaver.position = spawn_position
		a_beaver.set_unitID(1)
		a_beaver.set_team(team)
		if (check_resources(a_beaver)):
			reduce_resources(a_beaver)
			get_parent().add_child(a_beaver)
		else:
			a_beaver.free()
	
func spawn2() -> void:
	if (unitID == 1):
		var a_squirrel : Dynamic_Unit = squirrel.instantiate()
		a_squirrel.position = spawn_position
		a_squirrel.set_unitID(2)
		a_squirrel.set_team(team)
		if (check_resources(a_squirrel)):
			reduce_resources(a_squirrel)
			get_parent().add_child(a_squirrel)
		else:
			a_squirrel.free()
			
func spawn3() -> void:
	if (unitID == 1):
		var a_wolf : Dynamic_Unit = wolf.instantiate()
		a_wolf.position = spawn_position
		a_wolf.set_unitID(3)
		a_wolf.set_team(team)
		if (check_resources(a_wolf)):
			reduce_resources(a_wolf)
			get_parent().add_child(a_wolf)
		else:
			a_wolf.free()
			
func spawn4() -> void:
	if (unitID == 1):
		var a_bear : Dynamic_Unit = bear.instantiate()
		a_bear.position = spawn_position
		a_bear.set_unitID(4)
		a_bear.set_team(team)
		if (check_resources(a_bear)):
			reduce_resources(a_bear)
			get_parent().add_child(a_bear)
		else:
			a_bear.free()
		
func check_resources(unit: Dynamic_Unit) -> bool:
	if (team == 1):
		# order is [herb, wood, meat, mud, stone]
		var resources = get_parent().player_tribe.get_resources()

		for i in range(0, resources.size()):
			if (resources[i] < unit.cost[i]):
				return false
		return true
	else:
		return true
	
func reduce_resources(unit: Dynamic_Unit) -> void:
	if (team == 1):
		# order is [herb, wood, meat, mud, stone]
		get_parent().player_tribe.add_resources([-unit.cost[0],-unit.cost[1],-unit.cost[2],-unit.cost[3],-unit.cost[4]])
	else:
		pass
