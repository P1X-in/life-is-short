extends Spatial

var activated = false

func _ready():
	pass # Replace with function body.

func explode():
	$'../anim'.play("boom")

func is_activated():
	return self.activated
	
func activate():
	self.activated = true

func deactivate():
	self.activated = false
