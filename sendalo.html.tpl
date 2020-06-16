<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8"/>
		<title>Sendalo</title>

		<script>
			function downloadFile() {
				var file = document.getElementById('upload').files[0];
				if (file) {
					var fr = new FileReader();
					fr.onloadend = function() {
						downloadComplete(this.result);
					};
					fr.readAsArrayBuffer(file);
				} else {
					requestURL = document.getElementById('url').value;
					var xhr = new XMLHttpRequest();
					xhr.open('GET', requestURL);
					xhr.responseType = 'arraybuffer';

					xhr.onload = function () {
					    downloadComplete(this.response);
					};
					xhr.send();
				}
			}

			function downloadComplete(what) {
				FS.writeFile('/tmp/c2t.dsk', new Uint8Array(what));
				Module.callMain(['-n8', '/tmp/c2t.dsk', '/tmp/c2t.wav']);
				fd = FS.readFile('/tmp/c2t.wav', {encoding: 'binary'});
				b = new Blob([fd], { type: 'audio/wav' });
				u = URL.createObjectURL(b);
				audio = document.getElementById('audio');
				source = document.getElementById('source');
				source.src = u;
				audio.load();
				audio.play();
			}

			function fileSelected(ev) {
			}
		</script>
	</head>

	<body>
		<script>
			var Module = {
				print: (function(text) {
					console.log(text);
				}),
				printErr: (function(text) {
					console.log(text);
				})
			};
		</script>

		<input type="text" value="Misc_Apple_Programs_1.dsk" id="url"/>
		<input type="file" id="upload" />
		<input type="button" onclick="downloadFile()"/>

		<audio controls="controls" id="audio">
			<source id="source" src="" type="audio/wav" />
		</audio>

		{{{ SCRIPT }}}
	</body>
</html>
