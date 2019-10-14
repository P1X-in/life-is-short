extends StaticBody

var position

func _ready():
	pass

func run():
	get_parent().get_node("anim").play("run")

func die():
	queue_free()
