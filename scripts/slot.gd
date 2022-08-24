extends HBoxContainer
class_name Slot

onready var http_request: HTTPRequest = get_node("Request")

onready var pokemon_name_shadow: Label = get_node("PokemonNameShadow/Shadow")

onready var pokemon_id: Label = get_node("IdContainer/PokemonId")
onready var pokemon_name: Button = get_node("VContainer/PokemonName")
onready var pokemon_sprite: TextureRect = get_node("PokemonSprite")

var url: String = ""

export(PackedScene) var pokemon_page

#Conectando os sinais de mouse entrando/saindo da zona do container
#Apenas para dar um efeito visual
func _ready() -> void:
	var _exited: bool = connect("mouse_exited", self, "mouse_interaction", ["exited"])
	var _entered: bool = connect("mouse_entered", self, "mouse_interaction", ["entered"])
	
	
#Baseado no estado atual do mouse (Dentro ou Fora) do container
#Nós iremos mudar o alpha da cor, ou seja, quanto mais próximo de 0
#Mais transparente, quanto mais próximo de 1, mais visível
func mouse_interaction(state: String) -> void:
	match state:
		"exited":
			modulate.a = 1.0
			
		"entered":
			modulate.a = 0.5
			
			
#Método que é chamado assim que o slot é instanciado na cena principal
#Neste método nós estaremos recebendo as informações repassadas da main para
#O slot, modificando as suas propriedades para poder exibir o Pokemon
func init_slot(id: String, _name: String, _url, pokemon_texture: ImageTexture) -> void:
	url = _url
	
	pokemon_id.text = "#" + id
	
	pokemon_name.text = _name
	pokemon_name_shadow.text = _name
	pokemon_sprite.texture = pokemon_texture
	
	
#Basicamente esté método será chamado caso o usuário pressione
#O botão do Slot, botão responsável por levar até a página de informações
#Detalhadas do Pokemon

func spawn_pokemon_page() -> void:
	var page_to_instance = pokemon_page.instance()
	get_tree().root.call_deferred("add_child", page_to_instance)
	
	#Como nós já temos o nome e a imagem do pokemon, não é necessário realizar novas requisições
	#Para puxar os dados da Imagem, por exemplo
	page_to_instance._name = pokemon_name.text
	page_to_instance._image = pokemon_sprite.texture
	
	#Aqui nós conectamos o sinal de requisição finalizada, porém conectamos ele
	#Na página individual do Pokemon, como ela é apenas uma cena temporária que ficará
	#Na frente da Main, é possível realizar este tipo de ação
	var _request: bool = http_request.connect("request_completed", page_to_instance, "on_request_completed")
	
	var error = http_request.request(url)
	if error != OK:
		print("An error has ocurred")
		
		
#Sinal pressed conectado do botão, se ele for pressionado, significa
#Que o usuário quer acessar a página individual do Pokemon selecionado
func on_button_pressed() -> void:
	spawn_pokemon_page()
