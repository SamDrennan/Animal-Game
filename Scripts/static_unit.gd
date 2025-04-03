extends Unit

class_name Static_Unit

var beaver = preload("res://beaver.tscn")
var squirrel = preload("res://squirrel.tscn")
var wolf = preload("res://wolf.tscn")
var bear = preload("res://bear.tscn")

var unitID: int # 1 = tent, 2 = den
var spawn_position: Vector3

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
	
	if (self.health <= 0):
		var root = get_parent()
		root.get_node("GridMap").set_cell_item(self.position,-1)
		root.pathing.set_point_solid(Vector2i(self.position.x, self.position.z), false)
	
	super._process(delta)

func set_static_position(pos: Vector3) -> void:
	position = pos
	spawn_position = Vector3(self.position.x,self.position.y,self.position.z + 1)

func spawn1() -> void:
	if (unitID == 1):
		var a_beaver : Dynamic_Unit = beaver.instantiate()
		a_beaver.position = spawn_position
		a_beaver.unitID = 1
		a_beaver.set_team(team)
		get_parent().add_child(a_beaver)
	elif (unitID == 2):
		var a_wolf : Dynamic_Unit = wolf.instantiate()
		a_wolf.position = spawn_position
		a_wolf.unitID = 3
		a_wolf.set_team(team)
		get_parent().add_child(a_wolf)
	
func spawn2() -> void:
	if (unitID == 1):
		var a_squirrel : Dynamic_Unit = squirrel.instantiate()
		a_squirrel.position = spawn_position
		a_squirrel.unitID = 2
		a_squirrel.set_team(team)
		get_parent().add_child(a_squirrel)
	elif (unitID == 2):
		var a_bear : Dynamic_Unit = bear.instantiate()
		a_bear.position = spawn_position
		a_bear.unitID = 4
		a_bear.set_team(team)
		get_parent().add_child(a_bear)
