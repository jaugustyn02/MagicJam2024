extends Control

@export var Address = "localhost"
@export var Port = 2137

var peer

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func peer_connected(id):
	print("Player Connected", id)

func peer_disconnected(id):
	print("Player Disconnected", id)
	
func connected_to_server():
	print("Connected to Server")
	SendPlayerInformation.rpc_id(1, $LineEdit.text, multiplayer.get_unique_id())
	
func connection_failed():
	print("Couldn't Connect to Server")

@rpc("any_peer")
func SendPlayerInformation(name, id):
	if !GameManager.Players.has(id):
		GameManager.Players[id] = {
			"name": name,
			"id": id
		}
		
	if multiplayer.is_server():
		for i in GameManager.Players:
			SendPlayerInformation.rpc(GameManager.Players[i].name, i)
			
@rpc("any_peer", "call_local")
func StartGame():
	var scene = load("res://src/core/RootScene.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

@rpc("any_peer", "call_local")
func restart(player_id):
	print("Dupa")
	for n in get_children():
		n.queue_free()
	var scene = load("res://src/core/RootScene.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

func _on_host_button_down():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(Port, 2)
	if error != OK:
		print("Cannot host: ", error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_ZLIB)
	
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for Players")
	SendPlayerInformation($LineEdit.text, multiplayer.get_unique_id())

func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, Port)
	peer.get_host().compress(ENetConnection.COMPRESS_ZLIB)
	multiplayer.set_multiplayer_peer(peer)


func _on_start_game_button_down():
	StartGame.rpc()
