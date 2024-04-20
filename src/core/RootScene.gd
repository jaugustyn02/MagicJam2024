extends Node2D

@onready var HostID: int = $LevelManager.hostCharacterNode.name.to_int()
@onready var guestID: int = $LevelManager.guestCharacterNode.name.to_int()

# Called when the node enters the scene tree for the first time.
func _ready():
	$TimeController.time_multiplier_changed.connect($LevelManager.on_time_multiplier_changed)
	#$GuestHUD.characterNode = $LevelManager.guestCharacterNode
	#$HostHUD.characterNode = $LevelManager.hostCharacterNode
	$GuestHUD.set_character_node($LevelManager.guestCharacterNode)
	$HostHUD.set_character_node($LevelManager.hostCharacterNode)
	$TimeController.time_multiplier_changed.connect($Background_music.on_time_multiplier_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func end_game(lost_player_id: int):
	print("Player Lost: " + str(lost_player_id))
	var winnerName: String = ""
	if lost_player_id == HostID:
		winnerName = GameManager.Players[guestID].name
	else:
		winnerName = GameManager.Players[HostID].name
		
	end.rpc(winnerName)

@rpc("any_peer", "call_local")
func end(winnerName: String):
	await get_tree().create_timer(2.0).timeout
	Engine.time_scale = 0
	$EndScreen.set_winner_name(winnerName)
	$EndScreen.visible = true


@rpc("any_peer", "call_local")
func restart():
	#get_parent().visible = false
	#await get_tree().create_timer(2.0).timeout 
	#var scene = load("res://src/core/RootScene.tscn").instantiate()
	#get_tree().root.add_child(scene)
	Engine.time_scale = 1
	get_tree().change_scene_to_file("res://src/core/RootScene.tscn")
	#queue_free()


