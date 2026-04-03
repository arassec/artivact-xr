extends Node3D

@onready var audio_player = $AudioStreamPlayer3D
@onready var sprite: Sprite3D = $ButtonBase/rc_btn_model/Sprite3D

@export var toggleButton: bool
@export var type: SignalBus.SignalType
@export var iconOne: Texture:
	set(value):
		iconOne = value
@export var iconTwo: Texture:
	set(value):
		iconTwo = value

var toggleState: bool = true


func _ready():
	_update_icon()


func _on_button_pressed(_button: Variant) -> void:
	audio_player.play()
	SignalBus.trigger(type)
	toggleState = !toggleState


func _update_icon():
	if sprite:
		if toggleButton:
			if toggleState and iconOne:
				sprite.texture = iconOne
			elif !toggleState and iconTwo:
				sprite.texture = iconTwo
		elif iconOne: 
			sprite.texture = iconOne
