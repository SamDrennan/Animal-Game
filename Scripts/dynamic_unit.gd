extends Unit

class_name Dynamic_Unit

var unitID: int # 1 = Beaver, 2 = Squirrel, 3 = Wolf/cat for now, 4 = Bear
var destination: Vector3
var attacking: Unit
var speed: int = 3
var damage: int = 1
var isBled: bool
var cooldown: float = 0

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
			self.damage = 50
		4:
			label.text = "Bear"
	
func _process(delta: float) -> void:
	$Sprite3D/SubViewport/ProgressBar.value=health
	
	move(delta)
	#attack(delta)
	
	super._process(delta)
	
func _physics_process(delta: float) -> void:
	
	if (self.position.y >= 1 + (5 * delta)): # If in the air, fall towards the floor. Literally gravity
		self.position.y = self.position.y - (5 * delta)
		self.destination.y = self.position.y
			
func attack(delta: float) -> void:
	if (attacking != null):
		if ((attacking.position - self.position).length() < 1):
			destination = self.position
			if (cooldown <= 0):
				attacking.health -= self.damage
				cooldown = 1
			else:
				cooldown -= delta
		else:
			destination = attacking.position
	
	
func move(delta: float) -> void:
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
	pass

func attack_animation() -> void:
	pass
	
func die_animation() -> void:
	pass
	
func move_animation() -> void:
	pass
	
