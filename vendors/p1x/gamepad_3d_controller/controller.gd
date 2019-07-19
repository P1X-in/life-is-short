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

export var camera_min_deg = -80
export var camera_max_deg = 40

export var camera_min_distance = 2
export var camera_max_distance = 15

export var camera_rotate_speed = 1.5
export var camera_return_speed = 50.0

export var controller_enabled = true

var camera_pivot
var camera

var angle_y = 0
var _angle_y = 0

var camera_angle_y = 0
var _camera_angle_y = 0

var camera_angle_x = 0
var _camera_angle_x = 0

var raycast

func activate():
    self.controller_enabled = true

func deactivate():
    self.controller_enabled = false

func _ready():
    self.camera_pivot = $"camera_pivot"
    self.camera = $"camera_pivot/camera"
    self.raycast = $"camera_pivot/RayCast"

    var rotation = self.get_rotation_degrees()
    angle_y = rotation.y
    _angle_y = rotation.y

    rotation = self.camera_pivot.get_rotation_degrees()
    camera_angle_y = rotation.y
    _camera_angle_y = rotation.y
    camera_angle_x = rotation.x
    _camera_angle_x = rotation.x

    self.raycast.cast_to = Vector3(0, -1, self.camera_max_distance)
    self.raycast.add_exception(self)

    self.camera.set_translation(Vector3(0, 0, self.camera_max_distance))

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

        if abs(camera_angle_y - _camera_angle_y) < 0.001:
            _camera_angle_y = camera_angle_y

    if camera_angle_x != _camera_angle_x:
        angle_diff = (camera_angle_x - _camera_angle_x) * delta * self.camera_return_speed
        _camera_angle_x += angle_diff

        if abs(camera_angle_x - _camera_angle_x) < 0.001:
            _camera_angle_x = camera_angle_x

    self.camera_pivot.set_rotation_degrees(Vector3(_camera_angle_x, _camera_angle_y, 0))

func process_camera_collision():
    var distance = self.camera_max_distance
    if self.raycast.is_colliding():
        var raycast_collision = self.raycast.get_collision_point() - self.get_translation()
        distance = min(distance, raycast_collision.length() - 1.0)
        distance = max(distance, self.camera_min_distance)

    self.camera.set_translation(Vector3(0, 0, distance))

func _physics_process(delta):
    if not self.controller_enabled:
        return

    self.process_camera_input(delta)
    self.process_movement_input(delta)
    self.process_camera_collision()

func process_movement_input(delta):
    var axis_value = Vector2()
    var dir = Vector3()
    var vel = Vector3()

    vel.y += -self.GRAVITY
    axis_value.x = -Input.get_joy_axis(self.device_id, MOVEMENT_AXIS_X)
    axis_value.y = Input.get_joy_axis(self.device_id, MOVEMENT_AXIS_Y)

    axis_value = axis_value.rotated(deg2rad(self.angle_y + self.camera_angle_y))

    if axis_value.length() > self.DEADZONE:
        var angle = rad2deg(axis_value.angle()) + 90
        var angle_diff = angle - self.angle_y
        self.angle_y = angle
        self.camera_angle_y -= angle_diff

        axis_value = axis_value.normalized()

        dir.x = -axis_value.x
        dir.z = axis_value.y

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

    if abs(axis_value.y) > DEADZONE:
        camera_angle_x -= self.camera_rotate_speed * axis_value.y
        camera_angle_x = clamp(camera_angle_x, self.camera_min_deg, self.camera_max_deg)

