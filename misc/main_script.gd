extends Spatial

func _input(event):
    if Input.is_key_pressed(KEY_ESCAPE):
        quit_game()
    if not $infinite_terrain/player.controller_enabled:
        if Input.is_action_pressed("button_a"):
            next_scene("vendors/p1x/intro/intro")
        if Input.is_action_pressed("button_b"):
            next_scene("scenes/big/credits")

func quit_game():
    get_tree().quit()

func next_scene(path):
    get_tree().change_scene(path+".tscn")

func _on_music_finished():
    $music.play()
