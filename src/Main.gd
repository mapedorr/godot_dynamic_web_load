extends Control

var _assets_paths := {
	audio = [
		'mx_ingame.ogg',
		'mx_menu.ogg',
		'mx_tutorial.ogg',
		'ui_lose.ogg',
	],
	images = [
		'bg_bathroom_afternoon.png',
		'bg_cafeteria_afternoon.png',
		'bg_cafeteria_morning.png',
		'bg_cafeteria_night.png',
	]
}
var _requesters_container: Node


func _ready():
	$PanelContainer/Button.connect('pressed', get_parent(), 'load_restroom')
	
	for b in $PanelContainer/GridContainer.get_children():
		(b as TextureButton).connect('pressed', self, '_play_audio', [b.name])
	
	if OS.has_feature('assets_on_demand'):
		hide()
		HttpLoader.connect('asset_ready', self, '_asset_loaded')
		HttpLoader.connect('load_done', self, '_load_done')
		_requesters_container = HttpLoader.load_pack(self, _assets_paths)


func _play_audio(n: String) -> void:
	for a in $Audio.get_children():
		(a as AudioStreamPlayer).stop()
	(get_node('Audio/' + n) as AudioStreamPlayer).play()


func _asset_loaded(data: Dictionary):
	if data.type == 'image':
		($PanelContainer/GridContainer.get_child(data.idx) as TextureButton).texture_normal = data.res
	else:
		($Audio.get_child(data.idx) as AudioStreamPlayer).stream = data.res


func _load_done() -> void:
	remove_child(_requesters_container)
	_requesters_container.queue_free()
	show()
