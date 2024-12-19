extends Node

signal player_connected(peer_id, player_info)
signal all_players_ready
signal player_disconnected(peer_id)
signal server_disconnected
signal ping_response_arrived(time)
signal inputs_received(action_int, game_frame)

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1"

var players = {}
var player_info = {"name": "GG Player"}

var players_ready: int = 0

var delay = 2
var last_ping_time: float


func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func join_game(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer


func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, 1)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

	players[1] = player_info
	player_connected.emit(1, player_info)


func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null
	players.clear()


# When the server decides to start the game from a UI scene,
# do Network.load_game.rpc(filepath)
@rpc("call_local", "reliable")
func load_game(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)


# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_ready():
	players_ready += 1
	if players_ready == players.size():
		all_players_ready.emit()
		players_ready = 0


@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)


@rpc("any_peer", "reliable")
func ping(target: int, requesting := true):
	if requesting:
		last_ping_time = Time.get_unix_time_from_system()
		ping.rpc_id(target, target, false)
	else:
		pong.rpc_id(multiplayer.get_remote_sender_id())


@rpc("any_peer", "reliable")
func pong():
	ping_response_arrived.emit(Time.get_unix_time_from_system() - last_ping_time)


@rpc("any_peer", "reliable")
func send_inputs(action_int: int, game_frame: int):
	inputs_received.emit(action_int, game_frame)


# When a peer connects, send them my player info.
func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)


func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)


func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)


func _on_connected_fail():
	multiplayer.multiplayer_peer = null


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
