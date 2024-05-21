extends GutTest

var server:TwitchAuthServer

func before_all():
	server = load("res://addons/very-simple-twitch/auth_server.gd").new()
	
func test_start_server():
	server.start_server(13579)


func test_stop_server():
	server.stop()
	assert_eq(server._server, null)


