extends StaticBody

var animation

func _ready():
	self.animation = self.get_parent().get_node("anim")

func shake():
	self.animation.play("shake")

func fall():
	self.animation.play("fall")
	self.queue_free()
