extends Unit

class_name Dynamic_Unit

var unitID: int # 1 = Beaver, 2 = Squirrel, 3 = Wolf/cat for now, 4 = Bear
var destination: Vector3
var speed: int = 3
var damage: int = 1
var isBled: bool


func _init():
	# set super value
	super._init(100,0)

func _ready() -> void:
	destination = self.position
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
	
