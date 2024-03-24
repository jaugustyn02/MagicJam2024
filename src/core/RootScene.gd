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

