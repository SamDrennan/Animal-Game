extends Unit

class_name Dynamic_Unit

var unitID: int # 1 = Beaver, 2 = Squirrel, 3 = Wolf/cat for now, 4 = Bear
var destination: Vector3
var attacking: Unit
var speed: int = 3
var damage: int = 10
var isBled: bool
var cooldown: float = 0
var move_delay: float = 0

var path

func _init():
	# set super value
	super._init(100,0)

func _ready() -> void:
	destination = self.position
	path = []
	
	var label = $Sprite3D/SubViewport/Panel/Label
	match unitID:
		1:
			label.text = "Beaver"
		2:
			label.text = "Squirrel"
		3:
			label.text = "Wolf"
		4:
			label.text = "Bear"
	
func _process(delta: float) -> void:
	$Sprite3D/SubViewport/ProgressBar.value=health
	
	move(delta)
	attack(delta)
	
	super._process(delta)
	
func _physics_process(delta: float) -> void:
	pass
			
func attack(delta: float) -> void:
	
	if (cooldown > 0):
		cooldown -= delta
		
	if (attacking != null):
		if (self.team == attacking.team):
			attacking = null
		elif (cooldown <= 0 and (attacking.position - self.position).length() < 1.5):
			attacking.health -= self.damage
			cooldown = 1
			
	
	
func move(delta: float) -> void:	
	
	if (move_delay > 0):
		move_delay -= delta
	
	if (attacking != null):
		if (move_delay <= 0):
			set_path(get_parent().get_unit_path(position, attacking.position, true))
			move_delay = 0.1
	
	if (destination != self.position):
		var direction = self.position.direction_to(destination)
		var translation = direction*speed*delta
		
		if (self.position.distance_to(destination) < translation.length()):
			self.position = destination
			
		else:
			self.position += translation
			self.basis = Basis.looking_at(direction)
	elif path.size() > 0:
		destination = Vector3(path[0].x + .5, 1, path[0].y  + .5)
		path.pop_front()

func set_path(p):
	p.pop_front()
	path = p
	print(path)

func set_unitID(input: int) -> void:
	unitID = input
	match unitID:
		1:
			self.cost = [10, 0, 0, 0, 0]
		2:
			self.cost = [5, 10, 0, 0, 0]
		3:
			self.cost = [0, 10, 10, 0, 0]
		4:
			self.cost = [0, 10, 20, 0, 0]
