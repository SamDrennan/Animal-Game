extends Node

class_name Tribe

signal resource_updated(resource_name: String, value: int)

var meat: int
var herb: int
var wood: int
var mud: int
var stone: int

var units: Array


func _init():
	meat=0
	herb=0
	wood=0
	mud=0
	stone=0
	
	units=[]
	
func add_meat(amount: int):
	
	meat += amount
	emit_signal("resource_updated", "meat", meat)
	
func add_herb(amount: int):
	
	herb += amount
	emit_signal("resource_updated", "herb", herb)
	
func add_wood(amount: int):
	
	wood += amount
	emit_signal("resource_updated", "wood", wood)
	
func add_mud(amount: int):
	
	mud += amount
	emit_signal("resource_updated", "mud", mud)
	
func add_stone(amount: int):
	
	stone += amount
	emit_signal("resource_updated", "stone", stone)
	
func add_resources(amount: Array):
	# order is [herb, wood, meat, mud, stone]
	add_herb(amount[0])
	add_wood(amount[1])
	add_meat(amount[2])
	add_mud(amount[3])
	add_stone(amount[4])
	
func get_resources() -> Array:
	# order is [herb, wood, meat, mud, stone]
	return [herb,wood,meat,mud,stone]
