extends Control

#@export var Address = "192.168.1.26"
@export var Address = "127.0.0.1"
@export var Port = 2137

var peer
var defaultServerName = "Player1"
var defaultGuestName = "Player2"

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)

func _process(delta):
	pass

func peer_connected(id):
	print("Player Connected: ", id)
	if multiplayer.is_server():
		$ConsoleOutput.text = "Second Player Connected"

func peer_disconnected(id):
	print("Player Disconnected: ", id)
	$ConsoleOutput.text = "Second Player Disconnected"

func connected_to_server():
	print("Connected to Server")
	$ConsoleOutput.text = "Connected to Server"
	var playerName = $ButtonsContainer/NameInput.text
	playerName = playerName if playerName else defaultGuestName
	SendPlayerInformation.rpc_id(1, playerName, multiplayer.get_unique_id())

func connection_failed():
	print("Couldn't Connect to Server")
	$ConsoleOutput.text = "Couldn't Connect to Server"


@rpc("any_peer")
func SendPlayerInformation(name, id):
	if !GameManager.Players.has(id):
		GameManager.Players[id] = {
			"name": name,
			"id": id
		}
	
	if multiplayer.is_server():
		print("Player Connected with name: " + name)
		for i in GameManager.Players:
			SendPlayerInformation.rpc(GameManager.Players[i].name, i)

@rpc("any_peer", "call_local")
func StartGame():
	if multiplayer.get_peers().size() == 1:
	#var scene = load("res://src/core/RootScene.tscn").instantiate()
		get_tree().change_scene_to_file("res://src/core/RootScene.tscn")
	else:
		print("Cannot start without second player!")
		$ConsoleOutput.text = "Cannot Start without Second Player!"
	#get_tree().root.add_child(scene)
	#self.hide()
	#queue_free()


func _on_host_button_down():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(Port, 2)
	if error != OK:
		print("Cannot host: ", error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_ZLIB)
	
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for second player")
	$ConsoleOutput.text = "Waiting for second player"
	
	var playerName = $ButtonsContainer/NameInput.text
	playerName = playerName if playerName else defaultServerName
	SendPlayerInformation(playerName, multiplayer.get_unique_id())

func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	var Ip_input = $ButtonsContainer/IPInput.text
	if is_valid_ip_address(Ip_input):
		peer.create_client(Ip_input, Port)
		peer.get_host().compress(ENetConnection.COMPRESS_ZLIB)
		multiplayer.set_multiplayer_peer(peer)

func _on_start_game_button_down():
	StartGame.rpc()

func _on_quit_game_button_down():
	get_tree().quit()


func is_valid_ip_address(ip_address: String) -> bool:
	var ip_regex := "^([0-9]{1,3}\\.){3}[0-9]{1,3}$"
	var regex := RegEx.new()
	regex.compile(ip_regex)
	if regex.search(ip_address) != null:
		return true
	$ConsoleOutput.text = "Invalid IP Address!"
	return false
