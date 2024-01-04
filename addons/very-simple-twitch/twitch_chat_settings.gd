class_name TwitchSettings

const settings: Dictionary = {
	"client_id": {
		"path": "config/client_id",
		"type": TYPE_STRING,
		"hint_string": "The client id from the twitch developer dashboard",
		"is_basic": true,
		"initial_value": "",
	},
	"disk_cache_path": {
		"path": "advanced_config/disk_cache_path",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_GLOBAL_DIR,
		"hint_string": "The absolute filepath where the images cache will be stored",
		"is_basic": false,
		"initial_value": "user://very-simple-chat/cache",
	},
	"disk_cache": {
		"path": "config/disk_cache",
		"type": TYPE_BOOL,
		"hint_string": "Use cache to store the images from badges and emotes",
		"is_basic": true,
		"initial_value": true,
	},
	"scopes": {
		"path": "config/scopes",
		"type": TYPE_PACKED_STRING_ARRAY,
		"hint_string": "Scopes that will be asked when the token is retrieved",
		"is_basic": true,
		"initial_value": ["moderator:manage:banned_users","chat:read", "channel:manage:vips"],
	},
	"twitch_chat_url": {
		"path": "advanced_config/twitch_chat_url",
		"type": TYPE_STRING,
		"hint_string": "Twitch chat url",
		"is_basic": false,
		"initial_value": "wss://irc-ws.chat.twitch.tv",
	},
	"twitch_port": {
		"path": "advanced_config/twitch_port",
		"type": TYPE_INT,
		"hint_string": "The port the websocket will connect to",
		"is_basic": false,
		"initial_value": 443,
	},
	"twitch_anon_user": {
		"path": "advanced_config/twitch_anon_user",
		"type": TYPE_STRING,
		"hint_string": "Anon connection username",
		"is_basic": false,
		"initial_value": "justinfan5555",
	},
	"twitch_anon_pass": {
		"path": "advanced_config/twitch_anon_pass",
		"type": TYPE_STRING,
		"hint_string": "Anon connection password",
		"is_basic": false,
		"initial_value": "kappa",
	},
}

static func add_settings():
	for setting in settings:
		var setting_value = settings[setting]
		var path = "very_simple_twitch/"+ setting_value.get("path", "config" +setting)
		ProjectSettings.set_setting(path, setting_value.get("initial_value"))
		var property_info = {
			"name": path,
			"type": setting_value.get("type",  typeof(setting_value.get("initial_value"))),
			"hint": setting_value.get("hint"),
			"hint_string": setting_value.get("hint_string", "")
	}
		ProjectSettings.set_as_basic(path,  setting_value.get("is_basic", true))
		ProjectSettings.set_initial_value(path, setting_value.get("initial_value"))
		ProjectSettings.add_property_info(property_info)
	ProjectSettings.save()


static func remove_settings():
	for setting in settings:
		var setting_value = settings[setting]
		var path = "very_simple_twitch/"+ setting_value.get("path", "config") + "/" + setting 
		ProjectSettings.set_setting(path, null)


static func get_setting(setting: Dictionary):
	var path = "very_simple_twitch/"+ setting.get("path") 
	var response = ProjectSettings.get_setting(path)
	if !response:
		return setting.get("initial_value")
	else:
		return response
