extends "res://vendors/p1x/gamepad_3d_controller/controller.gd"

var coin = preload("res://models/coin/coin.gd")
var shroom = preload("res://models/shroom/shroom.gd")
var tree = preload("res://models/forest/tree.gd")

export var initial_scale = 0.4

var accumulated_delta = 0.0
var size = 1.0
const SIZE_LIMIT = 4.0
var far
var coins_count = 0

func _ready():
    ._ready()
    self.size = self.initial_scale
    self.set_scale(Vector3(self.size, self.size, self.size))
    self.far = self.camera.get_zfar()

onready var sounds = $"sounds/movement"

func _physics_process(delta):
    if not self.controller_enabled:
        return

    self.accumulated_delta += delta * 10
    if self.accumulated_delta > 2.0 * PI:
        self.accumulated_delta -= 2.0 * PI

    if self.is_moving:
        if not self.sounds.playing:
            self.sounds.play(randf()*4.0)
    else:
        self.sounds.stop()

    self.raycast.cast_to = Vector3(0, -1 * self.size, self.camera_max_distance * self.size)

func process_body_collision(collision):
    if collision.collider is self.coin:
        self.pick_up_coin(collision.collider)
    if collision.collider is self.shroom:
        self.eat_shroom(collision.collider)
    if collision.collider is self.tree:
        self.bump_tree(collision.collider)

func get_speed(factor):
    var sine_variance = (sin(self.accumulated_delta) + 1.0) / 4.0 + 0.5
    return self.move_max_speed * factor * sine_variance

func pick_up_coin(coin):
    coin.get_parent().get_node("anim").play("pick_up")
    $sounds/coin.play()
    coins_count += 1
    $".".get_parent().get_parent().get_node("gui/right/power/coins").update_coins(coins_count)
    coin.queue_free()

func eat_shroom(shroom):
    if self.size < self.SIZE_LIMIT:
        self.size += 0.1
        self.set_scale(Vector3(self.size, self.size, self.size))
        if self.size > 1.0:
            self.camera.set_zfar(self.far * self.size)
        self.move_max_speed += 2

        var fraction = (self.size - 0.1) / self.size
        self._camera_distance = self._camera_distance * fraction
        self.camera.set_translation(Vector3(0, 0, _camera_distance))

    shroom.eat()

func bump_tree(tree):
    if self.size > self.SIZE_LIMIT * .5:
        if self.size > self.SIZE_LIMIT * .75:
            tree.fall()
        else:
            tree.shake()

func raven_strike(raven):
    if self.size < 5.0:
        self.die()
    else:
        raven.die()

func kaiju_fight(kaiju):
    self.die()

func die():
    self.controller_enabled = false
    get_parent().get_parent().get_node("gui/titles/Viewport/Camera/titles/anim").play("wasted")
    get_parent().get_parent().get_node("gui/icons").hide()
    get_parent().get_parent().get_node("gui/wasted").show()
