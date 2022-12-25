extends Node

var server_client = ENetMultiplayerPeer.new()
var ip: String = "godotmmo.playit.gg"
#var ip = "127.0.0.1"

var port: int = 43578
var serverID: int = 1
var token: String = ""
var players_waiting_to_spawn: Dictionary = {}


func _ready():
	pass
	

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
	get_node("../Map").UpdateWorldState(world_state)
	

@rpc
func SendWorldState(_world_state):
	# for rpc checksum
	pass

	




