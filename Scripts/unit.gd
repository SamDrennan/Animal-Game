extends CharacterBody3D

class_name Unit

var health: int
var cost: Array[int] # order is [herb, wood, meat, mud, stone]
var sightRange: int
var selected: bool = false
var team: int 

func _init(health_v,sightRange_v):
	health = health_v
	sightRange=sightRange_v
	

func set_team(team_v: int):
	team = team_v
	var style = StyleBoxFlat.new()
	if (team == 1):
		style.bg_color = Color(0.1, 0.5, 0.1)  # Forest green, for example
	else:
		style.bg_color = Color(0.9, 0.1, 0.1)  # Forest green, for example
	$Sprite3D/SubViewport/ProgressBar.set("theme_override_styles/background", style)
	
func _process(delta: float) -> void:
	if (selected):
		$Highlight.visible = true
	else:
		$Highlight.visible = false
	if (self.health <= 0):
		self.free()
	
