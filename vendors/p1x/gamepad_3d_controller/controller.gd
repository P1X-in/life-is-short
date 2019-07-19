extends KinematicBody

const DEADZONE = 0.25
const GRAVITY = 9.8
const MOVEMENT_AXIS_X = JOY_ANALOG_LX
const MOVEMENT_AXIS_Y = JOY_ANALOG_LY
const CAMERA_AXIS_X = JOY_ANALOG_RX
const CAMERA_AXIS_Y = JOY_ANALOG_RY

export var device_id = 0
export var move_accel = 4.5
export var move_max_speed = 24
export var move_deaccel = 16
export var rotate_speed = 5.0
export var rotate_snap_speed = 50.0
export var max_slope_angle = 40

export var camera_rotate_speed = 1.5
export var camera_return_speed = 50.0

export var controller_enabled = true
export var with_camera_pivot = true
export var align_camera = false
export var rotate_camera_with_body = false

var camera_pivot
var camera

var angle_y = 0
var _angle_y = 0

var camera_angle_y = 0
var _camera_angle_y = 0

func _ready():
    self.camera_pivot = $"camera_pivot"
    self.camera = $"camera_pivot/camera"

func _process(delta):
    if not self.controller_enabled:
        return

    var angle_diff

    if angle_y != _angle_y:
        angle_diff = (angle_y - _angle_y) * delta * self.rotate_snap_speed
        _angle_y += angle_diff

        self.rotate_y(deg2rad(angle_diff))

    if camera_angle_y != _camera_angle_y:
        angle_diff = (camera_angle_y - _camera_angle_y) * delta * self.camera_return_speed
        _camera_angle_y += angle_diff

        self.camera_pivot.rotate_y(deg2rad(angle_diff))
        if abs(camera_angle_y - _camera_angle_y) < 0.001:
            _camera_angle_y = camera_angle_y

func _physics_process(delta):
    if not self.controller_enabled:
        return

    if self.with_camera_pivot:
        self.process_camera_input(delta)
    self.process_movement_input(delta)

func process_movement_input(delta):
    var axis_value = Vector2()

    axis_value.x = -Input.get_joy_axis(self.device_id, MOVEMENT_AXIS_X)
    axis_value.y = Input.get_joy_axis(self.device_id, MOVEMENT_AXIS_Y)

    axis_value = axis_value.rotated(deg2rad(self.angle_y + self.camera_angle_y))

    if axis_value.length() > self.DEADZONE:
        var angle = rad2deg(axis_value.angle()) + 90
        var angle_diff = angle - self.angle_y
        self.angle_y = angle
        self.camera_angle_y -= angle_diff

        var dir = Vector3()
        var vel = Vector3()
        axis_value = axis_value.normalized()

        dir.x = -axis_value.x
        dir.z = axis_value.y

        vel.y += -self.GRAVITY
        var hvel = vel
        hvel.y = 0

        var target = dir
        target *= self.move_max_speed
        var accel
        if dir.dot(hvel) > 0:
            accel = self.move_accel
        else:
            accel = self.move_deaccel

        hvel = hvel.linear_interpolate(target, accel * delta)
        vel.x = hvel.x
        vel.z = hvel.z
        vel = self.move_and_slide(vel, Vector3(0, 1, 0), true, 4, deg2rad(self.max_slope_angle))

func process_camera_input(delta):
    var axis_value = Vector2()

    axis_value.x = Input.get_joy_axis(self.device_id, CAMERA_AXIS_X)
    axis_value.y = Input.get_joy_axis(self.device_id, CAMERA_AXIS_Y)

    if abs(axis_value.x) > DEADZONE:
        camera_angle_y -= self.camera_rotate_speed * axis_value.x

