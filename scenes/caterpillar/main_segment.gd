extends "res://vendors/p1x/gamepad_3d_controller/controller.gd"

var coin = preload("res://models/coin/coin.gd")
var shroom = preload("res://models/shroom/shroom.gd")
var tree = preload("res://models/forest/tree.gd")
var raven = preload("res://models/raven/raven.gd")

export var initial_scale = 0.4

var accumulated_delta = 0.0
var size = 1.0
const SIZE_LIMIT = 10.0
var far

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

func process_body_collision(collision):
    if collision.collider is self.coin:
        self.pick_up_coin(collision.collider)
    if collision.collider is self.shroom:
        self.eat_shroom(collision.collider)
    if collision.collider is self.tree:
        self.bump_tree(collision.collider)
    if collision.collider is self.raven:
        self.raven_strike(collision.collider)

func get_speed(factor):
    var sine_variance = (sin(self.accumulated_delta) + 1.0) / 4.0 + 0.5
    return self.move_max_speed * factor * sine_variance

func pick_up_coin(coin):
    coin.get_parent().get_node("anim").play("pick_up")
    $sounds/coin.play()
    coin.queue_free()

func eat_shroom(shroom):
    if self.size < self.SIZE_LIMIT:
        self.size += 0.1
        self.set_scale(Vector3(self.size, self.size, self.size))
        self.camera.set_zfar(self.far * self.size)
        self.move_max_speed += 2

        var fraction = (self.size - 0.1) / self.size
        self._camera_distance = self._camera_distance * fraction
        self.camera.set_translation(Vector3(0, 0, _camera_distance))

    shroom.eat()

func bump_tree(tree):
    if self.size > 3.0:
        if self.size > 8.0:
            tree.fall()
        else:
            tree.shake()

func raven_strike(raven):
    self.controller_enabled = false
