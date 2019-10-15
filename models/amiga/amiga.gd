extends RigidBody

var coin = preload("res://models/coin/coin.gd")
var shroom = preload("res://models/shroom/shroom.gd")
var tree = preload("res://models/forest/tree.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	random_force()
	
	
func random_force():
	var rand_v3 = Vector3(randf()*500.0,randf()*500,randf()*500)
	apply_impulse(Vector3(0.0,0.0,0.0), rand_v3)
	print(rand_v3)
	
func pick_up_coin(coin):
	coin.pick_up()

func eat_shroom(shroom):
	shroom.eat()

func bump_tree(tree):
	tree.shake()
	random_force()

func die():
	queue_free()


func _on_RigidBody_body_entered(collision):
	if collision is self.coin:
		self.pick_up_coin(collision)
	if collision is self.shroom:
		self.eat_shroom(collision)
	if collision is self.tree:
		self.bump_tree(collision)
