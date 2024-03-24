extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$TimeController.time_multiplier_changed.connect($LevelManager.on_time_multiplier_changed)
	$GuestHUD.characterNode = $LevelManager.guestCharacterNode
	$HostHUD.characterNode = $LevelManager.hostCharacterNode
	$TimeController.time_multiplier_changed.connect($Background_music.on_time_multiplier_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func end_game(player_id):
	print(player_id)
	end.rpc()

@rpc("any_peer", "call_local")
func end():
	await get_tree().create_timer(2.0).timeout 
	$EndScreen.visible = true
	
	
@rpc("any_peer", "call_local")
func restart():
	get_parent().visible = false
	var scene = load("res://src/core/RootScene.tscn").instantiate()
	get_tree().root.add_child(scene)
	queue_free()


