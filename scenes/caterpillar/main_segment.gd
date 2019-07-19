extends "res://vendors/p1x/gamepad_3d_controller/controller.gd"

var coin = preload("res://models/coin/coin.gd")

func process_body_collision(collision):
    if collision.collider is self.coin:
        self.pick_up_coin(collision.collider)


func pick_up_coin(coin):
    coin.get_parent().queue_free()
