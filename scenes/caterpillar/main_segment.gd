extends "res://vendors/p1x/gamepad_3d_controller/controller.gd"

var coin = preload("res://models/coin/coin.gd")
var shroom = preload("res://models/shroom/shroom.gd")

var accumulated_delta = 0.0
var size = 1.0

func _physics_process(delta):
    if not self.controller_enabled:
        return

    self.accumulated_delta += delta * 10
    if self.accumulated_delta > 2.0 * PI:
        self.accumulated_delta -= 2.0 * PI

func process_body_collision(collision):
    if collision.collider is self.coin:
        self.pick_up_coin(collision.collider)
    if collision.collider is self.shroom:
        self.eat_shroom(collision.collider)

func get_speed(factor):
    var sine_variance = (sin(self.accumulated_delta) + 1.0) / 4.0 + 0.5
    return self.move_max_speed * factor * sine_variance

func pick_up_coin(coin):
    coin.get_parent().get_node("anim").play("pick_up")
    $sounds/coin.play()
    coin.queue_free()

func eat_shroom(shroom):
    var sounds = [$sounds/eat,$sounds/eat2,$sounds/eat3,$sounds/eat4]
    self.size += 0.1
    self.set_scale(Vector3(self.size, self.size, self.size))
    self.move_max_speed += 1
    shroom.eat()
    sounds[randi()%sounds.size()].play()
