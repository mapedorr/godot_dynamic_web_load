extends Node2D

var _assets_paths := {
	audio = [
		'lba_ed.mp3',
	],
	images = [
		'lol.png',
	]
}
var _requesters_container: Node

func _ready():
	if not OS.has_feature('assets_on_demand'):
		$AudioStreamPlayer2D.play()
	else:
		hide()
		HttpLoader.connect('asset_ready', self, '_asset_loaded')
		HttpLoader.connect('load_done', self, '_load_done')
		_requesters_container = HttpLoader.load_pack(self, _assets_paths)


func _asset_loaded(data: Dictionary):
	prints('Listo pa asignar')
	if data.type == 'image':
		$Sprite.texture = data.res
	else:
		$AudioStreamPlayer2D.stream = data.res


func _load_done() -> void:
	remove_child(_requesters_container)
	_requesters_container.queue_free()
	show()
	$AudioStreamPlayer2D.play()
