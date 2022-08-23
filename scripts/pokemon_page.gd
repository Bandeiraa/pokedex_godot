extends CanvasLayer
class_name PokemonPage

enum types {
	PRIMARY,
	SECONDARY
}

var _name: String
var _image: ImageTexture

onready var info_container: VBoxContainer = get_node("PokemonPage/InfoContainer")
onready var height: Label = info_container.get_node("Height")
onready var weight: Label = info_container.get_node("Weight")
onready var type: Label = info_container.get_node("Type")

onready var back_button: Button = get_node("PokemonPage/BackButton")

onready var page: Control = get_node("PokemonPage")
onready var pokemon_name: Label = page.get_node("VContainer/PokemonName")
onready var pokemon_image: TextureRect = page.get_node("VContainer/Image")

func _ready() -> void:
	pokemon_name.text = _name
	pokemon_image.texture = _image
	
	var _exited: bool = back_button.connect("mouse_exited", self, "mouse_interaction", ["exited", back_button])
	var _entered: bool = back_button.connect("mouse_entered", self, "mouse_interaction", ["entered", back_button])
	
	
func on_request_completed(_result, _response_code, _headers, body) -> void:
	var request_data: Dictionary = parse_json(body.get_string_from_utf8())
	
	var pokemon_type: Array = request_data["types"]
	
	var pokemon_height: float = request_data["height"] / 10
	var pokemon_weight: float = request_data["weight"] / 10
	
	height.text = "Height: " + str(pokemon_height) + " M"
	weight.text = "Weight: " + str(pokemon_weight) + " Kg"
	
	var type_list: Array = []
	
	for i in pokemon_type.size():
		type_list.append(pokemon_type[i]["type"]["name"])
		
	if type_list.size() == 1:
		type.text = "Type: " + type_list[types.PRIMARY]
		
	if type_list.size() == 2:
		type.text = "Types: " + type_list[types.PRIMARY] + ", " + type_list[types.SECONDARY]
		
	page.show()
	
	
func on_back_button_pressed() -> void:
	queue_free()
	
	
func mouse_interaction(state: String, target) -> void:
	match state:
		"exited":
			target.modulate.a = 1.0
			
		"entered":
			target.modulate.a = 0.5
