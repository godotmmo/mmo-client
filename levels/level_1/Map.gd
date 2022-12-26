extends Node3D

var player_spawn = preload("res://scripts/entity_scripts/Player/PlayerTemplate.tscn")
var last_world_state = 0
var world_state_buffer = []
const interpolation_offset = 100


func _ready():
	Server.MapNodeReady()
	

func _physics_process(delta):
	var render_time = Time.get_unix_time_from_system() - interpolation_offset
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[1].T:
			world_state_buffer.remove_at(0)
		var interpolation_factor = float(
			render_time - world_state_buffer[0]["T"]) / float(
				world_state_buffer[1]["T"] - world_state_buffer[0]["T"])
		for player in world_state_buffer[1].keys():
			if str(player) == "T":
				continue
			if player == multiplayer.get_unique_id():
				continue
			if not world_state_buffer[0].has(player):
				continue
			if get_node("../Map/OtherPlayers").has_node(str(player)):
				var new_position = lerp(world_state_buffer[0][player]["P"], world_state_buffer[1][player]["P"], interpolation_factor)
				get_node("../Map/OtherPlayers/" + str(player)).MovePlayer(new_position)
			else:
				print("Spawning player")
				SpawnNewPlayer(player, world_state_buffer[1][player]["P"])
				

func SpawnNewPlayer(player_id: int, spawn_position: Vector3):
	# check to make sure we are not double spawning the local player
	# check to make sure we are not double spawning other players
	if multiplayer.get_unique_id() != player_id and not get_node("../Map/OtherPlayers").has_node(str(player_id)):
		print("Map node spawing new player: " + str(player_id))
		var new_player = player_spawn.instantiate()
		new_player.position = spawn_position
		new_player.name = str(player_id)
		get_node("/root/Map/OtherPlayers").add_child(new_player)
	
		
		
func DespawnPlayer(player_id: String):
	get_node("/root/Map/OtherPlayers/" + str(player_id)).queue_free()


func UpdateWorldState(world_state: Dictionary):
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)
		
