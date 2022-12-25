extends Node

var gateway_client = ENetMultiplayerPeer.new()
var gateway_api: MultiplayerAPI = MultiplayerAPI.create_default_interface()

var ip: String = "december-antique.at.ply.gg"
var port: int = 44122

var username: String
var password: String
var new_account: bool = false
var peer_id

var cert = load("res://resources/certification/X509_Certificate.crt")



func _ready():
	pass
	
	
func _process(_delta):
	if !multiplayer.has_multiplayer_peer():
		return
	else:
		multiplayer.poll()

	
func ConnectToServer(_username: String, _password: String, _new_account: bool):
	username = _username
	password = _password
	new_account = _new_account
	
	# This defines our 'network' as a client peer
	gateway_client.create_client(ip, port)
	
	gateway_client.host.dtls_client_setup(cert, ip, false)
	
	# This creates a new multiplayer api instance on the current path and allows
	# for a secondary connection
	get_tree().set_multiplayer(gateway_api, get_path())
	gateway_api.set_multiplayer_peer(gateway_client)
	#print(multiplayer.get_multiplayer_peer().get_unique_id())
	gateway_api.connection_failed.connect(_OnConnectionFailed)
	gateway_client.peer_disconnected.connect(_OnConnectionDisconnected)
	gateway_api.connected_to_server.connect(_OnConnectionSucceeded)
	
	
func _OnConnectionFailed():
	print("Failed to connect to gateway server")
	# re-enabled all button on the login screen if the request fails
	get_node("/root/login_screen/Login/HBoxContainer/VBoxContainer/LoginButton").disabled = false
	get_node("/root/login_screen/Login/HBoxContainer/VBoxContainer/CreateAccountButton").disabled = false
	get_node("/root/login_screen/CreateAccount/HBoxContainer/VBoxContainer/Confirm").disabled = false
	get_node("/root/login_screen/CreateAccount/HBoxContainer/VBoxContainer/Back").disabled = false
	pass


func _OnConnectionDisconnected(_server_id):
	print("Disconnected")
	
	
func _OnConnectionSucceeded():
	#print("Succesfully connected to gateway server id: %d" % server_id)
	if new_account:
		RequestCreateAccount()
	else:
		LoginRequest(username, password)


@rpc(call_local)
func LoginRequest(_username, _password):
	#var peer_id = gateway.get_multiplayer_peer().get_unique_id()
	peer_id = 1
	print("Requesting login user. uid: " + str(peer_id))
	rpc_id(peer_id, "LoginRequest", _username, _password.sha256_text())
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
		get_node("/root/login_screen/Login/HBoxContainer/VBoxContainer/LoginButton").disabled = false
		get_node("/root/login_screen/Login/HBoxContainer/VBoxContainer/CreateUsernameButton").disabled = false
	multiplayer.disconnect("connection_failed", _OnConnectionFailed)
	gateway_client.disconnect("peer_disconnected", _OnConnectionDisconnected)
	gateway_api.disconnect("connected_to_server", _OnConnectionSucceeded)


@rpc(call_local)
func RequestCreateAccount():
	print("Requesting new account")
	rpc_id(1, "CreateAccountRequest", username, password.sha256_text())
	username = ""
	password = ""
	
@rpc
func CreateAccountRequest():
	# Needed for rpc checksum
	pass
	
@rpc(call_remote)
func ReturnCreateAccountRequest(results, message):
	print("Results from create account request recieved")
	if results == true:
		print("Account created")
		get_node("/root/login_screen")._on_back_pressed()
		get_node("/root/login_screen/CreateAccount/HBoxContainer/VBoxContainer/Confirm").disabled = false
		get_node("/root/login_screen/CreateAccount/HBoxContainer/VBoxContainer/Back").disabled = false
	else:
		if message == 1:
			print("Could not create account. Please try later.")
		elif message == 2:
			print("Username already exists")
			get_node("/root/login_screen/CreateAccount/HBoxContainer/VBoxContainer/Confirm").disabled = false
			get_node("/root/login_screen/CreateAccount/HBoxContainer/VBoxContainer/Back").disabled = false
	gateway_api.connection_failed.disconnect(_OnConnectionFailed)
	gateway_client.peer_disconnected.disconnect(_OnConnectionDisconnected)
	gateway_api.connected_to_server.disconnect(_OnConnectionSucceeded)

	
	
