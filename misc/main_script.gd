extends Spatial

func _ready():
	add_to_group("game")

func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		next_scene("scenes/big/menu")

func quit_game():
	get_tree().quit()

func next_scene(path):
	get_tree().change_scene(path+".tscn")

func _on_music_finished():
	$music.play()

func _on_menu_pressed():
	next_scene("scenes/big/menu")

func _on_play_pressed():
	next_scene("scenes/big/main")

func end_game():
	$infinite_terrain/player.controller_enabled = false
	get_tree().call_group("gui", "show_game_over")

func player_die():
	end_game()
	
func time_elapsed():
	end_game()
