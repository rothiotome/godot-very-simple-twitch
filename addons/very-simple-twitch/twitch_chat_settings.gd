class_name TwitchSettings

const settings: Dictionary = {
	"client_id": {
		"path": "config/client_id",
		"type": TYPE_STRING,
		"hint_string": "The client id from the twitch developer dashboard",
		"is_basic": true,
		"initial_value": "",
	},
	"redirect_host": {
		"path": "advanced_config/redirect_host",
		"type": TYPE_STRING,
		"hint_string": "The host where the OAuth Callback will be received",
		"is_basic": false,
		"initial_value": "http://localhost:",
	},
	"uuid": {
		"path": "advanced_config/uuid",
		"type": TYPE_STRING,
		"hint_string": "The useless UID to hide the token from the web browser",
		"is_basic": false,
		"initial_value": "53125396-3e32-4fad-8f7e-36475724168b-a8fe83ab-3373-4a6a-8967-2532eafe407f-41483db3-f011-4a23-80da-9a340672692a-e755c6d4-c546-43ce-b722-b5a799561b4e-5ba1697d-79b2-4d5d-96c3-f0d91f13f583-f08f18f9-bd56-4a0f-a597-96f90108cd85-14449d50-6cc9-450f-8119-ff4c525e31db-e41a6912-92a0-48b6-b6d3-845c21bea7eb-7dfd7948-2976-42cf-9cca-b23ae5854813-107224eb-81ea-46dd-9bf5-9ebbfcfc45dc/",
	},
	"redirect_port": {
		"path": "config/redirect_port",
		"type": TYPE_INT,
		"hint_string": "The port where the oauth callback will be redirect",
		"is_basic": true,
		"initial_value": 8090,
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
	"twitch_timeout_ms":{
		"path": "advanced_config/twitch_timeout_ms",
		"type:": TYPE_INT,
		"hint_string": "Time between messages sent by the client",
		"is_basic": false,
		"initial_value": 320,
	}
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
