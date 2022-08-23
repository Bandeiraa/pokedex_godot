extends Control
class_name Main

signal kill_request

onready var http_request: HTTPRequest = get_node("Request")
onready var v_container: VBoxContainer = get_node("ScrollList/VContainer")

var request_gap: int = 19

var current_index: int = 0
var current_pokemon_index: int = 0

var current_result_data: Dictionary

var url: String = "https://pokeapi.co/api/v2/pokemon?offset=0&limit=20"

export(PackedScene) var slot

func _ready() -> void:
	#Requisição Inicial para puxar os 20 primeiros pokemon
	pokemon_list_request()
	
	
func pokemon_list_request() -> void:
	if url == null:
		return
		
	var error = http_request.request(url)
	if error != OK:
		print("An error has ocurred!")
		
		
func initial_request(_result, _response_code, _headers, body) -> void:
	current_result_data = parse_json(body.get_string_from_utf8())
	url = current_result_data["next"]
	
	fill_slot(current_result_data["results"][current_index])
	
	
func fill_slot(result: Dictionary) -> void:
	var pokemon_url: String = result["url"]
	
	#Requisição para puxar os dados do pokemon -.-
	var new_http_request: HTTPRequest = HTTPRequest.new()
	add_child(new_http_request)
	
	var _kill_request: bool = connect("kill_request", new_http_request, "queue_free")
	var _pokemon_data: bool = new_http_request.connect("request_completed", self, "get_pokemon_data")
	var error = new_http_request.request(pokemon_url)
	if error != OK:
		print("An error has ocurred!")
		
		
func get_pokemon_data(_result: int, _response_code: int, _headers: PoolStringArray, body: PoolByteArray) -> void:
	emit_signal("kill_request")
	
	var serialized_data: Dictionary = parse_json(body.get_string_from_utf8())
	var pokemon_image_path: String = serialized_data["sprites"]["front_default"]
	
	var new_http_request: HTTPRequest = HTTPRequest.new()
	add_child(new_http_request)
	
	var _kill_request: bool = connect("kill_request", new_http_request, "queue_free")
	var _pokemon_image: bool = new_http_request.connect("request_completed", self, "get_pokemon_image")
	
	var error = new_http_request.request(pokemon_image_path)
	if error != OK:
		print("An error has ocurred!")
		
		
func get_pokemon_image(_result: int, _response_code: int, _headers: PoolStringArray, body: PoolByteArray) -> void:
	emit_signal("kill_request")
	
	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	if error != OK:
		push_error("Couldn't load the image.")
		
	var texture: ImageTexture = ImageTexture.new()
	texture.create_from_image(image, 1)
	
	var current_pokemon_result = current_result_data["results"][current_index]
	add_slot(current_pokemon_index + 1, current_pokemon_result["name"], current_pokemon_result["url"], texture)
	
	current_index += 1
	current_pokemon_index += 1
	if current_index == request_gap + 1:
		current_index = 0
		request_gap = request_gap + request_gap
		pokemon_list_request()
		return
		
	fill_slot(current_result_data["results"][current_index])
	
	
func add_slot(pokemon_id: int, pokemon_name: String, pokemon_url: String, pokemon_texture: ImageTexture) -> void:
	var slot_to_add = slot.instance()
	v_container.add_child(slot_to_add)
	slot_to_add.init_slot(str(pokemon_id), pokemon_name, pokemon_url, pokemon_texture)
