extends Node3D

class_name Unit

var health: int
var cost: Array[int]
var sightRange: int

func _init(health_v,sightRange_v):
	health = health_v
	
	sightRange=sightRange_v
	
func _process(delta: float) -> void:
	if (self.health <= 0):
		self.free()
