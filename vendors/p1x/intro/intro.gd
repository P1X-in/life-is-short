extends Spatial

export var next_scene_bigfile = "scenes/big/main"
export var first_button_path = "main/menu/panel/buttons/start"
export var has_buttons = false


func _ready():
	if has_buttons: activate_first_button()

func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		quit_game()
		
func _on_quit_pressed():
	quit_game()
	
func quit_game():
	get_tree().quit()

func next_scene():
	get_tree().change_scene(next_scene_bigfile+".tscn")

func _on_start_pressed():
	next_scene()

func _on_creds_pressed():
	pass

func activate_first_button():
	get_node(first_button_path).grab_focus()
