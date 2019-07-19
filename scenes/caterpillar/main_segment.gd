extends "res://vendors/p1x/gamepad_3d_controller/controller.gd"

var coin = preload("res://models/coin/coin.gd")

func process_body_collision(collision):
    if collision.collider is self.coin:
        self.pick_up_coin(collision.collider)


func pick_up_coin(coin):
    coin.get_parent().queue_free()
    #self.set_scale(self.get_scale() + Vector3(0.1, 0.1, 0.1))
    #self.camera_pivot.set_scale(self.camera_pivot.get_scale() - 0.5)
