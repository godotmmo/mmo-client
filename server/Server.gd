extends Node

var server_client = ENetMultiplayerPeer.new()
var ip: String = "godotmmo.playit.gg"
#var ip = "127.0.0.1"

var port: int = 43578
var serverID: int = 1
var token: String = ""
var players_waiting_to_spawn: Dictionary = {}
var latency_msecs: int = 0
var client_clock_msecs: int = 0
var delta_latency_msecs: int = 0
var decimal_collector: float = 0
var latency_array: Array = []


func _physics_process(delta):
	client_clock_msecs += int(delta*1000) + delta_latency_msecs
	delta_latency_msecs = 0
	decimal_collector += (delta * 1000) - int(delta * 1000)
	if decimal_collector >= 1.00:
		client_clock_msecs += 1
		decimal_collector -= 1

func MapNodeReady():
	for _player_id in players_waiting_to_spawn.keys():
		SpawnNewPlayer(_player_id, players_waiting_to_spawn[_player_id])


func ConnectToServer():
	server_client.create_client(ip, port)
	multiplayer.set_multiplayer_peer(server_client)
	print("Set multi peer for server")
	
	server_client.peer_disconnected.connect(_OnConnectionFailed)
	server_client.peer_connected.connect(_OnConnectionSucceeded)
	
	
func _OnConnectionFailed(_server_id):
	print("Failed to connect")
	

func _OnConnectionSucceeded(server_id):
	print("Succesfully connected to server id: %d" % server_id)
	FetchServerTime()
	
	
func _DetermineLatency():
	DetermineLatency()

	
@rpc(call_local)
func FetchServerTime():
	while not multiplayer.get_peers().has(1):
		await get_tree().create_timer(1).timeout
	rpc_id(1, "FetchServerTime", int(Time.get_unix_time_from_system() * 1000))
	var timer: Timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.timeout.connect(_DetermineLatency)
	get_parent().add_child(timer)


@rpc(call_local)
func DetermineLatency():
	rpc_id(1, "DetermineLatency", int(Time.get_unix_time_from_system() * 1000))
	

@rpc(call_remote)
func ReturnLatency(client_time_msecs: int):
	latency_array.append((int(Time.get_unix_time_from_system() * 1000) - client_time_msecs) / 2)
	if latency_array.size() == 9:
		var total_latency: int = 0
		latency_array.sort()
		var mid_point: int = latency_array[4]
		for i in range(latency_array.size()-1, -1, -1):
			if latency_array[i] > (2 * mid_point) and latency_array[i] > 20:
				latency_array.remove_at(i)
			else:
				total_latency += latency_array[i]
		delta_latency_msecs = (total_latency / latency_array.size()) - latency_msecs
		latency_msecs = total_latency / latency_array.size()
		print("New latency ", latency_msecs)
		print("Delta latency ", delta_latency_msecs)
		latency_array.clear()


@rpc(call_remote)
func ReturnServerTime(server_time_msecs, client_time_msecs):
	print("Return Server Time called")
	latency_msecs = (int(Time.get_unix_time_from_system() * 1000) - client_time_msecs) / 2
	client_clock_msecs = int(server_time_msecs + latency_msecs)


@rpc(call_local)
func FetchSkillData(skill_name, requester):
	rpc_id(serverID, "FetchSkillData", skill_name, requester)
	

@rpc
func ReturnSkillData(skill_data, skill_name, requester):
	instance_from_id(requester).SetAbilityValue(skill_data, skill_name)
	

@rpc
func FetchPlayerData():
	pass
	
	
@rpc
func ReturnPlayerData():
	pass


@rpc
func FetchToken(_player_id):
	print("Fetching token")
	rpc_id(1, "ReturnToken", token)
	
	
@rpc
func ReturnToken(_token):
	pass
	
	
@rpc
func ReturnTokenVerificationResults(_player_id, result):
	if result == true:
		#get_node(".").queue_free()
		get_tree().change_scene_to_file("res://levels/level_1/level_1.tscn")
		print("Successful token verification")
	else:
		print("Login failed. Please try again.")
		#enable the login button
		get_node("/root/login_screen/NinePatchRect/HBoxContainer/VBoxContainer/LoginButton").disabled = false
		
		
@rpc(any_peer)
func SpawnNewPlayer(_player_id, _spawn_position):
	# check to see if the player id passed is the local player
	if multiplayer.get_unique_id() != _player_id:
		# make sure the Map is loaded in, otherwise add to the player queue
		if get_node("../Map"):
			print("rpc spawn player reached and map loaded")
			get_node("../Map").SpawnNewPlayer(_player_id, _spawn_position)
		else:
			print("appending player to wait-list")
			players_waiting_to_spawn.values().append({_player_id: _spawn_position})
	else:
		print("Cannot run spawn player for local player")
	
	
@rpc
func DespawnPlayer(_player_id):
	get_node("/root/Map").DespawnPlayer(_player_id)
	
	
@rpc(call_local, unreliable)
func SendPlayerState(player_state):
	rpc_id(1, "ReceivePlayerState", player_state)
	
	
@rpc
func ReceivePlayerState(_player_state):
	# for rpc checksum
	pass
	
	
@rpc(call_remote, unreliable)
func ReceiveWorldState(world_state):
		if get_node("/root").has_node("Map"):
			get_node("../Map").UpdateWorldState(world_state)


@rpc
func SendWorldState(_world_state):
	# for rpc checksum
	pass

	




