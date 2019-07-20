extends KinematicBody

export var index = 0

var main_segment = null
var stored_movement = []
var arbitrary_offset = 1

func _ready():
    self.main_segment = self.get_parent().get_node("player")

func _physics_process(delta):
    if self.main_segment == null:
        return


    var move = {
        'translation' : self.main_segment.get_translation(),
        'rotation' : self.main_segment.get_rotation()
    }

    if self.stored_movement.size() > 0:
        var back = self.stored_movement.back()
        if move['translation'].distance_to(back['translation']) < 0.01:
            return

    self.stored_movement.push_back(move)

    if self.stored_movement.size() > self.arbitrary_offset * self.index:
        move = self.stored_movement.pop_front()
        self.set_translation(move['translation'])
        self.set_rotation(move['rotation'])

    var scale = self.main_segment.get_scale()
    self.set_scale(scale)
    if scale.x / 0.5 > self.arbitrary_offset:
        self.arbitrary_offset += 1
