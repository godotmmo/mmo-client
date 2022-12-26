extends Node3D

var player_spawn = preload("res://scripts/entity_scripts/Player/PlayerTemplate.tscn")
var last_world_state = 0
var world_state_buffer = []
const interpolation_offset: int = 100
var interpolation_factor: float


func _ready():
	Server.MapNodeReady()

func _physics_process(_delta):
	var render_time = Server.client_clock_msecs - interpolation_offset
	if world_state_buffer.size() > 1:
		#print(world_state_buffer.size())
		#if world_state_buffer.size() > 3:
		#	print(world_state_buffer[0], world_state_buffer[1], world_state_buffer[2])
		#print(render_time, "|", world_state_buffer[1].T)
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
			#print("cleaning buffer")
			world_state_buffer.remove_at(0)
		if world_state_buffer.size() > 2: # We have a future world state | Interpolate
			interpolation_factor = float(render_time - world_state_buffer[1]["T"]) / float(world_state_buffer[2]["T"] - world_state_buffer[1]["T"])
			for player in world_state_buffer[2].keys():
				if str(player) == "T":
					continue
				if player == multiplayer.get_unique_id():
					continue
				if not world_state_buffer[1].has(player):
					continue
				if get_node("../Map/OtherPlayers").has_node(str(player)):
					#print(interpolation_factor)
					var new_position = world_state_buffer[1][player]["P"].lerp(world_state_buffer[2][player]["P"], clamp(interpolation_factor, 0, 1))
					#print(new_position, ": from interpolation")
					#print("moving player [", str(player), "] to position [", str(new_position), "]")
					get_node("../Map/OtherPlayers/" + str(player)).MovePlayer(new_position)
				else:
					print("Spawning player")
					SpawnNewPlayer(player, world_state_buffer[2][player]["P"])
		elif render_time > world_state_buffer[1].T: # There is no future world state | Extrapolate
			var extrapolation_factor = float(render_time - world_state_buffer[0]["T"]) / clamp(float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"]), 0.0001, 100000) - 1.00
			print(extrapolation_factor, "extrapolation factor")
			for player in world_state_buffer[1].keys():
				if str(player) == "T":
					continue
				if player == multiplayer.get_unique_id():
					continue
				if not world_state_buffer[0].has(player):
					continue
				if get_node("../Map/OtherPlayers").has_node(str(player)):
					var position_delta: Vector3 = (world_state_buffer[1][player]["P"] - world_state_buffer[0][player]["P"])
					print(position_delta, ": position delta")
					var position_extrapolation: Vector3 = position_delta * extrapolation_factor
					print(position_extrapolation, ": position extrapolation")
					#var new_position_x: float = world_state_buffer[1][player]["P"].x
					#var new_position_y: float = world_state_buffer[1][player]["P"].y
					#var new_position_z: float = world_state_buffer[1][player]["P"].z
					var new_position: Vector3 = world_state_buffer[1][player]["P"] + position_extrapolation
					print(new_position, ": new position from extrapolation")

					get_node("../Map/OtherPlayers/" + str(player)).MovePlayer(new_position)
					

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
	await get_tree().create_timer(0.2).timeout
	get_node("/root/Map/OtherPlayers/" + str(player_id)).queue_free()


func UpdateWorldState(world_state: Dictionary):
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)
		
