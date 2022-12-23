extends Node

var network = ENetMultiplayerPeer.new()

var ip: String = "december-antique.at.ply.gg"
var port: int = 44122

var username: String
var password: String
var peer_id
var gateway: MultiplayerAPI = MultiplayerAPI.create_default_interface()


func _ready():
	pass
	
	
func _process(delta):
	if !multiplayer.has_multiplayer_peer():
		return
	else:
		multiplayer.poll()

	
func ConnectToServer(_username, _password):
	network = ENetMultiplayerPeer.new()
	username = _username
	password = _password
	
	# This defines our 'network' as a client peer
	network.create_client(ip, port)
	
	# This creates a new multiplayer api instance on the current path and allows
	# for a secondary connection
	get_tree().set_multiplayer(gateway, get_path())
	gateway.set_multiplayer_peer(network)
	#print(multiplayer.get_multiplayer_peer().get_unique_id())
	gateway.connection_failed.connect(_OnConnectionFailed)
	network.peer_disconnected.connect(_OnConnectionDisconnected)
	gateway.connected_to_server.connect(_OnConnectionSucceeded)
	
	
func _OnConnectionFailed(server_id):
	print("Failed to connect to gateway server")
	get_node("res://gui/login/login.tscn/NinePatchRect/HBoxContainer/VBoxContainer/LoginButton")
	pass


func _OnConnectionDisconnected(server_id):
	print("Disconnected")
	
	
func _OnConnectionSucceeded():
	#print("Succesfully connected to gateway server id: %d" % server_id)
	LoginRequest(username, password)


@rpc(call_local)
func LoginRequest(_username, _password):
	#var peer_id = gateway.get_multiplayer_peer().get_unique_id()
	peer_id = 1
	print("Requesting login user. uid: " + str(peer_id))
	rpc_id(peer_id, "LoginRequest", _username, _password)
	username = ""
	password = ""


@rpc
func ReturnLoginRequest(result, token):
	print("results received")
	# if valid login request, set server token and connect to game server
	if result == true:
		Server.token = token
		Server.ConnectToServer()
	else:
		# if invalid login, unlock the login button
		print("Please provide a correct username and password")
		print(get_node("."))
		get_node("/root/login_screen/NinePatchRect/HBoxContainer/VBoxContainer/LoginButton").disabled = false
	multiplayer.disconnect("connection_failed", _OnConnectionFailed)
	network.disconnect("peer_disconnected", _OnConnectionDisconnected)
	gateway.disconnect("connected_to_server", _OnConnectionSucceeded)

	
	
