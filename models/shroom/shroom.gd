extends StaticBody

var animation
var used = false

func _ready():
	self.animation = self.get_parent().get_node("anim")

func eat():
	self.used = true
	self.animation.play("eat")
	self.destroy()

func destroy():
	self.queue_free()

func is_used():
	return self.used
