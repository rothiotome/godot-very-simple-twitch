extends GutTest

var server:VSTAuthServer

func before_all():
	server = load("res://addons/very-simple-twitch/auth_server.gd").new()

func after_all():
	server.queue_free()

func test_handle_post():
	var mock_client:StreamPeer = double(StreamPeerBuffer).new()
	#test nothing happens
	server.handlePost(mock_client, "http://localhost:8080")
	watch_signals(server)
	assert_signal_not_emitted(server, "OnTokenReceived")
	#test nothing happens
	server.handlePost(mock_client, "http://localhost:8080?im_not_a_token_param=12345")
	assert_signal_not_emitted(server, "OnTokenReceived")
	#test token is spread
	server.handlePost(mock_client, "http://localhost:8080?token=12345")
	assert_signal_emitted_with_parameters(server, "OnTokenReceived",["12345"])


func test_handle_get():
	var mock_client:StreamPeer = double(StreamPeerBuffer).new()
	server.handleGet(mock_client)
	var data_to_200:Array = mock_client.get_data(8)
	assert_ne_deep(data_to_200, [])


func test_load_login_page():
	var page:String = server.loadLoginPage()
	assert_ne(page, null)
	assert_ne(page, "")
