extends Unit

class_name Dynamic_Unit

var unitID: int # 1 = Beaver, 2 = Squirrel, 3 = Wolf/cat for now, 4 = Bear
var destination: Vector3
var attacking: Unit
var damage: int = 10
var speed: int = 3
var cooldown: float = 0
var move_delay: float = 0

# resource gathering variables
var harvesting: int = 0 # 0 nothing, 1 herb, 2 wood, 3 meat, 4 mud, 5 stone
var harvest_location: Vector3
var carrying: Array # index 0 is resource type, 1 is amount
var returning: bool = false
var collect_cooldown: float = 0

# Enemy AI variables
enum State {
	IDLE,
	ATTACK,
	RETREAT
}
var current_state: State = State.IDLE
var find_enemy_cooldown: = 0

var path

var animation

func _init():
	# set super value
	super._init(100,0)

func _ready() -> void:
	destination = self.position
	path = []
	animation=$AnimationPlayer
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
			#animation=$AnimationPlayer
	
func _process(delta: float) -> void:
	$Sprite3D/SubViewport/ProgressBar.value=health
	
	if (team == 2):
		match current_state:
			State.IDLE:
				idle_behavior()
			State.ATTACK:
				attack_behavior(delta)
			State.RETREAT:
				retreat_behavior(delta)
	
	move(delta)
	harvest(delta)
	attack(delta)
	
	super._process(delta)
	
func _physics_process(delta: float) -> void:
	pass
			
func attack(delta: float) -> void:
	
	if (cooldown > 0):
		cooldown -= delta
		
	if (find_enemy_cooldown > 0):
		find_enemy_cooldown -= delta
		
	if (team == 2):
		if (current_state == State.ATTACK and find_enemy_cooldown <= 0):
			var enemy = find_nearest_enemy()
			if enemy:
				attacking = enemy
				find_enemy_cooldown = 1
		
	if (attacking != null):
		if (self.team == attacking.team):
			attacking = null
		elif (cooldown <= 0 and (attacking.position - self.position).length() < 1.8):
			attacking.health -= self.damage
			cooldown = 1
			animation.play("attacking")
			if attacking.health <=0:
				attacking = null
				if (unitID == 3):
					animation.pause()
	

func harvest(delta: float) -> void:
	
	if (collect_cooldown > 0):
		collect_cooldown -= delta
	
	# 0 nothing, 1 herb, 2 wood, 3 meat, 4 mud, 5 stone
	if (unitID == 1 and harvesting != 0):
		var tent_pos
		if (team == 1):
			tent_pos = get_parent().player_tent_position
		else:
			tent_pos = get_parent().enemy_tent_position
		
		if ((harvest_location - position).length() < 2 and not returning):
			animation.play("gathering")
			if (collect_cooldown <= 0):
				carrying = []
				carrying.resize(5)
				carrying.fill(0)
				carrying[harvesting - 1] = 10
				collect_cooldown = 2
				set_path(get_parent().get_unit_path(position, tent_pos, true))
				returning = true
			
		elif ((tent_pos - position).length() < 2 and returning):
			if (team == 1):
				get_parent().player_tribe.add_resources(carrying)
			carrying = []
			set_path(get_parent().get_unit_path(position, harvest_location, true))
			returning = false
			
		elif (path.size() == 0 and not returning):
			set_path(get_parent().get_unit_path(position, harvest_location, true))
		elif (path.size() == 0 and returning):
			set_path(get_parent().get_unit_path(position, tent_pos, true))
	
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
		
		animation.play("running")
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
			
func idle_behavior():
	if (unitID != 1):
		if (health >= 50):
			var enemy = find_nearest_enemy()
			if enemy:
				attacking = enemy
				current_state = State.ATTACK
	elif (unitID == 1 and harvesting == 0):
		harvesting = randi_range(1,5)
		harvest_location = find_nearest_resource(harvesting)
		
func attack_behavior(delta):
	if not is_instance_valid(attacking):
		attacking = null
		current_state = State.IDLE
		return
	if (health <= 20):
		attacking = null
		path = []
		while (path.size() == 0):
			var enemy_tent_pos = get_parent().enemy_tent_position
			var retreat_pos = Vector3(randi_range(enemy_tent_pos.x - 5,enemy_tent_pos.x + 5), enemy_tent_pos.y, randi_range(enemy_tent_pos.z - 5,enemy_tent_pos.z + 5))
			set_path(get_parent().get_unit_path(position, retreat_pos, true))
		speed = 2
		current_state = State.RETREAT
		return
		
func retreat_behavior(delta):
	if (path.size() == 0):
		current_state = State.IDLE
		return
	

func find_nearest_enemy() -> Node3D:
	var enemies = get_tree().get_nodes_in_group("player_units")
	var nearest: Node3D = null
	var nearest_dist = 100
	for e in enemies:
		var dist = position.distance_to(e.position)
		if dist <= nearest_dist:
			nearest = e
			nearest_dist = dist
	return nearest
	
func find_nearest_resource(type: int) -> Vector3:
	# 1 herb, 2 wood, 3 meat, 4 mud, 5 stone
	var resource_list
	match type:
		1:
			resource_list = get_parent().herb
		2:
			resource_list = get_parent().tree
		3:
			resource_list = get_parent().depot
		4:
			resource_list = get_parent().mud
		5:
			resource_list = get_parent().stone
			
	var nearest_dist = 100
	var nearest
	for location in resource_list:
		var dist = position.distance_to(location)
		if dist <= nearest_dist:
			nearest = location
			nearest_dist = dist
	return nearest
