extends "res://vendors/p1x/gamepad_3d_controller/controller.gd"

var coin = preload("res://models/coin/coin.gd")

var accumulated_delta = 0.0

func _physics_process(delta):
    if not self.controller_enabled:
        return

    self.accumulated_delta += delta * 10
    if self.accumulated_delta > 2.0 * PI:
        self.accumulated_delta -= 2.0 * PI

func process_body_collision(collision):
    if collision.collider is self.coin:
        self.pick_up_coin(collision.collider)

func get_speed(factor):
    var sine_variance = (sin(self.accumulated_delta) + 1.0) / 4.0 + 0.5
    return self.move_max_speed * factor * sine_variance

func pick_up_coin(coin):
    #self.set_scale(self.get_scale() + Vector3(0.1, 0.1, 0.1))
    #self.camera_pivot.set_scale(self.camera_pivot.get_scale() - 0.5)
    coin.get_parent().get_node("anim").play("pick_up")
    coin.queue_free()
