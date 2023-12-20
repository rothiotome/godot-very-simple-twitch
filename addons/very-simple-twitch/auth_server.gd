class_name TwitchAuthServer

extends Node

signal OnTokenReceived(token: String)

var SERVER_IDENTITY = 'AUTH_SERVER'
var TOKEN_KEY = 'token'
var AUTHENTICATION_REDIRECT_FILE_PATH = 'res://addons/very-simple-twitch/public/index.html'

var _clients: Array[StreamPeerTCP] = []
var _server: TCPServer


func start_server(port: int):
	_server = TCPServer.new()
	_server.listen(port)
	print("Server started")


func stop_server():
	if _server:
		_server.stop()
	_server = null
	print("Server stopped")


func _process(_delta: float) -> void:
	if !_server:
		return

	var newConnection = _server.take_connection()
	if newConnection:
		_clients.push_back(newConnection)

	for client in _clients:
		if client.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			continue

		var bytes = client.get_available_bytes()
		# after finisher reading bytes clear connection
		_clients = _clients.filter(func (item): return item != client)
		var requestAsString = client.get_string(bytes)
		if requestAsString.length() < 1:
			continue

		var requestInformation = requestAsString.split('\n')[0].split(' ')
		var method = requestInformation[0]
		var url = requestInformation[1]

		match method:
			'GET':
				# send html login page
				handleGet(client)
			'POST':
				# handle token extraction
				handlePost(client, url)


func handlePost(client: StreamPeer, url: String):
	var urlSplitted = url.split('?')
	var query = urlSplitted[1]
	var token = getTokenFromQuery(query)
	if !token:
		return
	OnTokenReceived.emit(token)
	send200(client)
	stop_server()
	queue_free()


func handleGet(client: StreamPeer):
	var pageAsString = loadLoginPage()
	send200(client, pageAsString)


func getTokenFromQuery(query: String):
	var queryKeyValues = query.split('&')
	for keyValue in queryKeyValues:
		var splittedKeyValue = keyValue.split('=')
		var key = splittedKeyValue[0]
		if key == TOKEN_KEY:
			return splittedKeyValue[1]


func send200(client: StreamPeer, data: String = "", content_type: String = "text/html"):
	var dataAsBuffer = data.to_ascii_buffer()
	client.put_data(("HTTP/1.1 %d %s\r\n" % [200, 'OK']).to_ascii_buffer())
	client.put_data(("Server: %s\r\n" % SERVER_IDENTITY).to_ascii_buffer())
	client.put_data(("Content-Length: %d\r\n" % dataAsBuffer.size()).to_ascii_buffer())
	client.put_data("Connection: close\r\n".to_ascii_buffer())
	client.put_data(("Content-Type: %s\r\n\r\n" % content_type).to_ascii_buffer())
	client.put_data(dataAsBuffer)


func loadLoginPage():
	var file = FileAccess.open(AUTHENTICATION_REDIRECT_FILE_PATH, FileAccess.READ)
	var loadedFile: String = file.get_as_text()
	file.close()
	return loadedFile
