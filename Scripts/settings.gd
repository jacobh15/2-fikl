extends Node

var logged_in = false

func _on_login_button_pressed() -> void:
	$MainContents/ScrollMargin/SettingsScroller/Settings/LoginButton/Spinbox.visible = true
	$MainContents/ScrollMargin/SettingsScroller/Settings/LoginButton.disabled = true
