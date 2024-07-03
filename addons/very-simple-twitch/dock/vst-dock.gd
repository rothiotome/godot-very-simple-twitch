@tool
extends Control

@onready var copy_button: Button = %CopyButton
@onready var redirect_uri = %RedirectURI
@onready var client_id_line_edit = %ClientIDLineEdit
@onready var client_id_warning = %ClientIDWarning
@onready var help_icon = %HelpIcon
@onready var warning_icon = %WarningIcon


func _ready():
	help_icon.texture = get_theme_icon("Help", "EditorIcons")
	warning_icon.texture = get_theme_icon("StatusWarning", "EditorIcons")
	copy_button.icon = get_theme_icon("ActionCopy", "EditorIcons")
	copy_button.tooltip_text = "Copy Redirect URL to clipboard"
	client_id_warning.add_theme_color_override("font_color", EditorInterface.get_editor_settings().get_setting("text_editor/theme/highlighting/comment_markers/warning_color"))
	visibility_changed.connect(on_visibility_changed)


func on_visibility_changed():
	if visible:
		update_visuals()
		ProjectSettings.settings_changed.connect(update_visuals)
	else:
		if ProjectSettings.settings_changed.is_connected(update_visuals):
			ProjectSettings.settings_changed.disconnect(update_visuals)


func update_visuals():
	var client_id = TwitchSettings.get_setting(TwitchSettings.settings.client_id)
	var redirect_host = TwitchSettings.get_setting(TwitchSettings.settings.redirect_host)
	var redirect_port = TwitchSettings.get_setting(TwitchSettings.settings.redirect_port)
	var uuid = TwitchSettings.get_setting(TwitchSettings.settings.uuid)
		
	redirect_uri.text = redirect_host + str(redirect_port) + "/" + uuid
	client_id_line_edit.text = client_id
	if client_id == "":
		client_id_warning.show()
		warning_icon.show()
	else:
		client_id_warning.hide()
		warning_icon.hide()


func copy_redirect_uri():
	DisplayServer.clipboard_set(redirect_uri.text)


func client_id_submitted():
	ProjectSettings.set_setting("very_simple_twitch/"+TwitchSettings.settings.client_id.path, client_id_line_edit.text)
	ProjectSettings.save()
	

func open_url(meta):
	OS.shell_open(meta)
