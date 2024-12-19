extends Control

@onready var name_input: LineEdit = $VBoxContainer/SettingsPanel/MarginContainer/VBoxContainer/NameRow/NameInput
@onready var delay_input: SpinBox = $VBoxContainer/SettingsPanel/MarginContainer/VBoxContainer/DelayRow/DelayInput
@onready var host_address: LineEdit = $VBoxContainer/TabContainer/Host/HBoxContainer/LineEdit
@onready var host_button: Button = $VBoxContainer/TabContainer/Host/HBoxContainer/Button
@onready var join_address: LineEdit = $VBoxContainer/TabContainer/Connect/HBoxContainer/LineEdit
@onready var join_button: Button = $VBoxContainer/TabContainer/Connect/HBoxContainer/Button
@onready var connected_panel: PanelContainer = $VBoxContainer/ConnectedPanel
@onready var player_label: Label = $VBoxContainer/ConnectedPanel/MarginContainer/VBoxContainer/PlayerNameBox/PlayerLabel
@onready var ping_label: Label = $VBoxContainer/ConnectedPanel/MarginContainer/VBoxContainer/PingBox/PingLabel
@onready var start_btn: Button = $VBoxContainer/ConnectedPanel/MarginContainer/VBoxContainer/StartBtn
@onready var ping_timer: Timer = $VBoxContainer/ConnectedPanel/PingTimer

var connected_player_id: int


func _ready() -> void:
	delay_input.value = Network.delay
	connected_panel.hide()
	Network.player_connected.connect(_on_player_connected)
	Network.player_disconnected.connect(_on_player_disconnected)
	Network.server_disconnected.connect(_on_server_disconnected)
	Network.ping_response_arrived.connect(_on_ping_response)
	Network.all_players_ready.connect(_on_players_ready)


func _on_players_ready():
	get_tree().change_scene_to_file("res://fight.tscn")


func _on_player_connected(peer_id, player_info):
	if peer_id == multiplayer.get_unique_id():
		return
	
	connected_player_id = peer_id
	player_label.text = player_info.name
	connected_panel.show()
	ping_timer.start()


func _on_player_disconnected(peer_id):
	ping_timer.stop()
	connected_panel.hide()
	print("%s: player %d disconnected" % [name_input.text, peer_id])


func _on_server_disconnected():
	print("%s: server disconnected" % name_input.text)


func _on_ping_response(time):
	ping_label.text = "%3dms" % (time*1000)


func _on_name_input_text_changed(new_text: String) -> void:
	Network.player_info.name = new_text


func _on_host_button_pressed() -> void:
	Network.create_game()
	Global.player_side = 1


func _on_join_button_pressed() -> void:
	Network.join_game(join_address.text)
	Global.player_side = 2


func _on_tab_changed(_tab: int) -> void:
	Network.remove_multiplayer_peer()
	connected_panel.hide()
	ping_timer.stop()


func _on_start_button_pressed() -> void:
	Network.player_ready.rpc()


func _on_ping_timer_timeout() -> void:
	Network.ping(connected_player_id)


func _on_delay_input_value_changed(value: float) -> void:
	Network.delay = int(value)
