extends Unit

class_name Dynamic_Unit

var unitID: int
var destination: Vector3
var speed: int = 3
var damage: int = 1
var isBled: bool

func _ready() -> void:
	destination = self.position

func _process(delta: float) -> void:
	if (destination != self.position):
		var direction = self.position.direction_to(destination)
		var translation = direction*speed*delta
		
		if (self.position.distance_to(destination) < translation.length()):
			self.position = destination
			
		else:
			self.position += translation
			self.basis = Basis.looking_at(direction)
			
			
func _physics_process(delta: float) -> void:
	
	if (self.position.y >= 1 + (5 * delta)): # If in the air, fall towards the floor. Literally gravity
		self.position.y = self.position.y - (5 * delta)
		self.destination.y = self.position.y
			
func attack_animation() -> void:
	pass
	
func die_animation() -> void:
	pass
	
func move_animation() -> void:
	pass
	
