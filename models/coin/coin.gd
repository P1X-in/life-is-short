extends Spatial

var used = false

func _ready():
	pass

func pick_up():
	self.used = true
	self.get_parent().get_node("sound").play()
	self.destroy()

func destroy():
	self.get_parent().get_node("anim").play("pick_up")
	self.queue_free()

func is_used():
	return self.used
