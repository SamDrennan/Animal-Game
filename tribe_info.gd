extends Panel

class_name Tribe_info

var tribe: Tribe
# Called when the node enters the scene tree for the first time.

func setup(tribe_node: Tribe):
	tribe = tribe_node
   
	tribe.resource_updated.connect(_on_resource_updated)
	
	_update_all_labels()
	
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_resource_updated(resource_name: String, value: int):
	match resource_name:
		"meat": $meat_num.text = str(value)
		"herb": $herb_num.text = str(value)
		"wood": $wood_num.text = str(value)
		"mud": $mud_num.text = str(value)
		"stone": $stone_num.text = str(value)

# 更新所有 Label
func _update_all_labels():
	$meat_num.text = str(tribe.meat)
	$herb_num.text = str(tribe.herb)
	$wood_num.text = str(tribe.wood)
	$mud_num.text = str(tribe.mud)
	$stone_num.text = str(tribe.stone)
