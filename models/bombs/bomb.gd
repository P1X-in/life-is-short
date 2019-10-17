extends Spatial

var activated = false

func _ready():
	pass # Replace with function body.

func explode():
	$'../anim'.play("boom")
	self.queue_free()

func explode_and_activate():
	$'../anim'.play("boom_and_activate")
	
func is_activated():
	return self.activated
	
func activate():
	self.activated = true

func deactivate():
	self.activated = false
