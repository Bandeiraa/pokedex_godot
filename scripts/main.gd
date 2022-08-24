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
	#Requisição Inicial para puxar a lista dos 20 primeiros pokemon
	#Está lista irá conter o nome e a url de cada pokemon individual
	pokemon_list_request()
	
	
func pokemon_list_request() -> void:
	#Prevenindo o projeto de quebrar ou bugar, caso a url seja igual a nulo
	if url == null:
		return
		
	var error = http_request.request(url)
	if error != OK:
		print("An error has ocurred!")
		
		
#Caso a requisição seja concluída, nós iremos transformar os dados
#Em um dicionário, em seguida iremos modificar a url (dos próximos 20 pokemon a serem carregados)
func initial_request(_result, _response_code, _headers, body) -> void:
	current_result_data = parse_json(body.get_string_from_utf8())
	url = current_result_data["next"]
	
	fill_slot(current_result_data["results"][current_index])
	
	
#Baseado no current_index ^ nós iremos saber qual o pokemon atual. Ex: no index 0 temos o Bulbasaur
#No index 1, o Ivysaur e assim em diante

#A partir deste index, nós iremos realizar uma nova requisição para puxar as informações detalhadas
#De cada Pokemon
func fill_slot(result: Dictionary) -> void:
	var pokemon_url: String = result["url"]
	
	#Requisição para puxar os dados do pokemon -.-
	var new_http_request: HTTPRequest = HTTPRequest.new()
	add_child(new_http_request)
	
	#Lógica utilizando os sinais da Godot, para sempre " matar " o novo HttpRequest que é criado
	#Sempre que nós precisamos realizar uma nova requisição
	#Lembrando que ele só vai ser " morto " após finalizar a requisição
	
	var _kill_request: bool = connect("kill_request", new_http_request, "queue_free")
	var _pokemon_data: bool = new_http_request.connect("request_completed", self, "get_pokemon_data")
	var error = new_http_request.request(pokemon_url)
	if error != OK:
		print("An error has ocurred!")
		
		
#Com os dados detalhados de cada Pokemon, agora é necessário realizar um nova requisição
#Precisamos acessar o campo "sprites/"front_default", para puxar a Imagem do Pokemon
func get_pokemon_data(_result: int, _response_code: int, _headers: PoolStringArray, body: PoolByteArray) -> void:
	emit_signal("kill_request")
	
	var serialized_data: Dictionary = parse_json(body.get_string_from_utf8())
	var pokemon_image_path = serialized_data["sprites"]["front_default"]
	
	if pokemon_image_path == null:
		return
		
	var new_http_request: HTTPRequest = HTTPRequest.new()
	add_child(new_http_request)
	
	var _kill_request: bool = connect("kill_request", new_http_request, "queue_free")
	var _pokemon_image: bool = new_http_request.connect("request_completed", self, "get_pokemon_image")
	
	var error = new_http_request.request(pokemon_image_path)
	if error != OK:
		print("An error has ocurred!")
		
		
#Basicamente aqui nós estamos " criando " a imagem do pokemon a partir da requisição dos dados
#Da sua url
func get_pokemon_image(_result: int, _response_code: int, _headers: PoolStringArray, body: PoolByteArray) -> void:
	emit_signal("kill_request")
	
	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	if error != OK:
		push_error("Couldn't load the image.")
		
	var texture: ImageTexture = ImageTexture.new()
	texture.create_from_image(image, 1)
	
	#Com todos os dados do Pokemon armazenados, agora é possível adicionar o slot do pokemon
	#Este slot inicial conta com a sua Imagem, nome e id
	
	var current_pokemon_result = current_result_data["results"][current_index]
	add_slot(current_pokemon_index + 1, current_pokemon_result["name"], current_pokemon_result["url"], texture)
	
	#Estamos acrescendo o index em 1, este que sempre varia entre 0 a 19
	#Pois nós estamos realizando requisições para puxar pokemon de 20 em 20
	
	#Sempre acrescemos o current pokemon index, pois é a partir dele que nós definimos
	#O id de cada pokemon
	
	current_index += 1
	current_pokemon_index += 1
	
	#Se o indice atual for igual ao máximo de requisições de um bloco de 20 pokemon/requisições
	#Então nós precisamos realizar uma requisição para chamar a lista dos novos 20 pokemon
	#Além de zerar o current_index
	
	if current_index == request_gap + 1:
		current_index = 0
		pokemon_list_request()
		return
		
	#Caso ele não entre no if acima, significa que nós ainda não chegamos no final
	#Da lista de 20 pokemon/requisições
	fill_slot(current_result_data["results"][current_index])
	
	
#Método para instanciar um slot, este slot que estará responsável por ter um botão que
#Irá levar o usuário até a tela com informações mais detalhadas sobre cada pokemon
func add_slot(pokemon_id: int, pokemon_name: String, pokemon_url: String, pokemon_texture: ImageTexture) -> void:
	var slot_to_add = slot.instance()
	v_container.add_child(slot_to_add)
	slot_to_add.init_slot(str(pokemon_id), pokemon_name, pokemon_url, pokemon_texture)
