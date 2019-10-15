extends Spatial

func _ready():
	pass

func pick_up():
	get_parent().get_node("anim").play("pick_up")
	get_parent().get_node("sound").play()
	queue_free()
