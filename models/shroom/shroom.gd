extends StaticBody

var animation

func _ready():
    self.animation = self.get_parent().get_node("anim")

func eat():
    self.animation.play("eat")
    self.queue_free()