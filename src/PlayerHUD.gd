extends Control

var characterNode
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_character_node(characterNode):
	if characterNode:
		self.characterNode = characterNode
		var id: int = characterNode.name.to_int()
		$PlayerName.text = GameManager.Players[id].name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if characterNode:
		$TimeCounter.update_lifetime(characterNode.lifetime)
		$TimeBar.update_lifetime(characterNode.lifetime)
