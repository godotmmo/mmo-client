extends Node3D

var player_spawn = preload("res://scripts/entity_scripts/Player/PlayerTemplate.tscn")
var last_world_state = 0

func _ready():
	Server.MapNodeReady()


func SpawnNewPlayer(player_id: int, spawn_position: Vector3):
	# check to make sure we are not double spawning the local player
	# check to make sure we are not double spawning other players
	if multiplayer.get_unique_id() != player_id and not get_node("../Map/OtherPlayers").has_node(str(player_id)):
		print("Map node spawing new player: " + str(player_id))
		var new_player = player_spawn.instantiate()
		new_player.position = spawn_position
		new_player.name = str(player_id)
		get_node("/root/Map/OtherPlayers").add_child(new_player)
	
		
		
func DespawnPlayer(player_id: int):
	get_node("/root/Map/OtherPlayers/" + str(player_id)).queue_free()


func UpdateWorldState(world_state: Dictionary):
	# buffer
	# interpolation
	# extrapolation
	# rubber banding
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state.erase("T") # will be needed when implementing interpolation and extrapolation
		world_state.erase(multiplayer.get_unique_id())
		for player in world_state.keys():
			if get_node("../Map/OtherPlayers").has_node(str(player)):
				get_node("../Map/OtherPlayers/" + str(player)).MovePlayer(world_state[player]["P"])
			else:
				print("Spawning player")
				SpawnNewPlayer(player, world_state[player]["P"])
