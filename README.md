![Last release: 0.0.1](https://img.shields.io/badge/release-v0.0.1a-blue.png) 
![Download in the AssetLib](https://img.shields.io/badge/AssetLib-Soon-FA5c5c?logo=godot&logoColor=FFFFFF&)
[![Made for Godot](https://img.shields.io/badge/Godot-4.x-blue?logo=godotengine&logoColor=white)](https://godotengine.org)
[![Under MIT license](https://img.shields.io/github/license/RothioTome/godot-very-simple-twitch)](LICENSE)

![Logo](./icon.svg)
# Godot Very Simple Twitch
A very simple plugin to connect your Godot games to the Twitch chat. It's possible to Login with just one line of code and start reading the messages. Custom settings for different environments and more complex login methods are also supported.

## Table of contents
- [How to install](#how-to-install)
- [How to use](#how-to-use)
    - [Login](#how-to-login)
        - [Simple annonymous connection](#simple-anonymous-connection)
        - [Get Token and login to channel](#get-token-and-login-to-channel)
    - [Receive chat messages](#how-to-receive-chat-messages)
    - [Send chat messages](#how-to-send-chat-messages)
- [Editor Dock](#editor-dock)
- [FAQ and Troubleshooting](#faq-and-troubleshooting)
    - [Change Settings](#change-settings)
- [License](#license)

## How to install
Godot Very Simple Twitch requires Godot 4.2 or higher. You can check the Godot version you have installed in the bottom dock or your editor.
- Clone the project or download last release.
- If you cloned the project, extract the ```addons``` folder
- Move the ```addons``` fodler to your game folder

To verify the installation is correct:
- The folder path ```res://addons/very-simple-twitch``` exists
- Go to ```Project > Project Settings```
- Click in the ```Plugins```tab
- Enable ```Very Simple Twitch```
- Restart Godot

## How to Use

## How to Login
### Simple anonymous connection
This is the easiest way to use the plugin. You can use ``VerySimpleTwitch.login_chat_anon("channel_name")`` to connect to the channel without needing a token or any settings customization.

```
var channel_name: String = "channel_name"

VerySimpleTwitch.login_chat_anon(channel_name)
```

### Get Token and login to channel
You can use ``VerySimpleTwitch.get_token_and_login_chat()`` to retrieve the token and automatically login to the 
```
VerySimpleTwitch.get_token_and_login()
```

> Note: You will need to set up the CLIENT_ID in the Settings tab and configure the Twitch app accordingly.

## How to receive chat messages
To receive the Twitch chat messages, connect the `chat_message_received` signal from VerySimpleTwitch. The signal contains all the information available from the chatter, including display_name, badges, tags and colors.
```
func _ready():
    VerySimpleTwitch.chat_message_received.connect(print_chatter_msg)

func print_chatter_message(chatter: Chatter):
    print("Message received from %s: %s % [chatter.tags.display_name, escape_bbcode(chatter.message)])
```

## How to send chat messages
To send chat messages you can use the ``VerySimpleTwitch.send_chat_message("Hello world")`` static method. Sending chat messages is only available when you use OAuth connection method with a Token that has writting permissions.

## Editor Dock

## FAQ and Troubleshooting
### Change Settings
You can change the Settings in ``Project > Project Settings > General > Very Simple Twitch``. Note that switching on the ``Advanced Settings`` toggle will allow you to customize even more your client. Advanced Config are not supposed to be changed without further knowledge on how Twitch works. 

## License
This project is released under the MIT License by RothioTome (2024)