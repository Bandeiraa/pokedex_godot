extends HBoxContainer
class_name Slot

onready var http_request: HTTPRequest = get_node("Request")

onready var pokemon_name_shadow: Label = get_node("PokemonNameShadow/Shadow")

onready var pokemon_id: Label = get_node("IdContainer/PokemonId")
onready var pokemon_name: Button = get_node("VContainer/PokemonName")
onready var pokemon_sprite: TextureRect = get_node("PokemonSprite")

var url: String = ""

export(PackedScene) var pokemon_page

func _ready() -> void:
	var _exited: bool = connect("mouse_exited", self, "mouse_interaction", ["exited"])
	var _entered: bool = connect("mouse_entered", self, "mouse_interaction", ["entered"])
	
	
func mouse_interaction(state: String) -> void:
	match state:
		"exited":
			modulate.a = 1.0
			
		"entered":
			modulate.a = 0.5
			
			
func init_slot(id: String, _name: String, _url, pokemon_texture: ImageTexture) -> void:
	url = _url
	
	pokemon_id.text = "#" + id
	
	pokemon_name.text = _name
	pokemon_name_shadow.text = _name
	pokemon_sprite.texture = pokemon_texture
	
	
func spawn_pokemon_page() -> void:
	var page_to_instance = pokemon_page.instance()
	get_tree().root.call_deferred("add_child", page_to_instance)
	
	page_to_instance._name = pokemon_name.text
	page_to_instance._image = pokemon_sprite.texture
	
	var _request: bool = http_request.connect("request_completed", page_to_instance, "on_request_completed")
	
	var error = http_request.request(url)
	if error != OK:
		print("An error has ocurred")
		
		
func on_button_pressed() -> void:
	spawn_pokemon_page()
