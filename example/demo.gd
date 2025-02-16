extends Node

func login_anon():
	await VerySimpleTwitch.login_chat_anon(%ChannelName.text)
	_show_logout_layout()

func login_token():
	await VerySimpleTwitch.get_token_and_login_chat()
	_show_logout_layout()

func logout():
	VerySimpleTwitch.end_chat_client()
	%TwitchChat.clear()
	_show_login_layout()

func _on_test_connection_pressed() -> void:
	VerySimpleTwitch.is_connected_to_server(func (connection_result):
		print("Connected? -> %s" % str(connection_result))
	)

#region Local methods to simplify demo
func _show_login_layout():
	%TabContainer.set_tab_disabled(0, false)
	%TabContainer.set_tab_disabled(1, false)
	%LoggedLayout.hide()
	%LoginToken.show()
	%LoginAnon.show()
	%ChannelName.editable = true
	%ChannelName.selecting_enabled = true

func _show_logout_layout():
	%TabContainer.set_tab_disabled(0, true)
	%TabContainer.set_tab_disabled(1, true)
	%LoginAnon.hide()
	%LoggedLayout.show()
	%LoginToken.hide()
	%ChannelName.editable = false
	%ChannelName.selecting_enabled = false


func clear_chat() -> void:
	%TwitchChat.clear()


func _on_oauth_title_toggle_toggled(toggled_on: bool) -> void:
	_update_toggle_icon(%OauthTitleToggle, toggled_on)


func _on_anonymous_title_toggle_toggled(toggled_on: bool) -> void:
	_update_toggle_icon(%AnonymousTitleToggle, toggled_on)


func _update_toggle_icon(toggle_button: Button, toggled_on: bool) -> void:
	var icon_path = "res://example/arrow_down.svg" if toggled_on else "res://example/arrow_right.svg"
	var icon = load(icon_path)
	toggle_button.icon = icon

#endregion
