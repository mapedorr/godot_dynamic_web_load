extends Node

signal asset_ready(dic)
signal load_done

const ASSETS_PATH := 'http://127.0.0.1:3002/on_demand/assets/%s/%s'

var _total_files := 0
var _loaded_files := 0

func load_pack(container: Node, assets_pack: Dictionary) -> Node:
	_total_files = 0
	_loaded_files = 0
	
	var requesters_container := Node.new()
	container.add_child(requesters_container)

	for type in assets_pack:
		var idx := 0
		for asset in assets_pack[type]:
			var ext: String = asset.get_extension()
			
			var http_request = HTTPRequest.new()
			requesters_container.add_child(http_request)
			http_request.connect(
				'request_completed', self, '_http_request_completed', [ext, idx]
			)

			var error = http_request.request(ASSETS_PATH % [type, asset])
			if error != OK:
				push_error('An error occurred in the HTTP request.')

			idx += 1
			_total_files += 1

	return requesters_container


func _http_request_completed(result, response_code, headers, body, ext, idx):
	_loaded_files += 1
	
	if ext == 'png':
		var image = Image.new()
		var error = image.load_png_from_buffer(body)
		if error != OK:
			push_error('Couldn\'t load the image.')

		var texture = ImageTexture.new()
		texture.create_from_image(image)
		
		emit_signal('asset_ready', {
			type = 'image',
			idx = idx,
			res = texture
		})
	else:
		var audio_stream: AudioStream

		if ext == 'mp3':
			audio_stream = AudioStreamMP3.new()
		else:
			audio_stream = AudioStreamOGGVorbis.new()

		audio_stream.data = body
		
		emit_signal('asset_ready', {
			type = 'audio',
			idx = idx,
			res = audio_stream
		})
	
	if _loaded_files == _total_files:
		emit_signal('load_done')
