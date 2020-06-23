<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1" />
        <meta name="apple-mobile-web-app-capable" content="yes" />
        <link rel="apple-touch-icon" href="apple-touch-icon.png"/>
        <link rel="icon" type="image/png" href="apple-touch-icon.png" /> 

        <title>Sendalo</title>

        <style>
            body {
                background-color: #707087;
                font-family: sans-serif;
                font-size: 1em;
                color: white;               
            }

            h1, h2 {
                text-align: center;
                padding: 0.2em;
                margin: 0;
            }

            h2 {
                font-weight: normal;
                font-size: 0.9em;
            }

            li {
                margin-bottom: 0.7em;
            }

            a, a:visited {
                color: white;
            }

            form {
                text-align: center;
            }
            
            #w {
                text-align: center;
            }

            #expl {
                display: none;
            }

            input#url {
                width: 300px;
                font-size: 1.1em;
                max-width: 90%;
            }
            
            input#upload {
                width: 300px;
                max-width: 90%;
                text-align: left;
            }
            
            footer {
                margin-top: 2em;
                font-size: 0.8em;
            }
            
            #audiopad {
                display: block;
                width: 100%;
                max-width: 300px;
                margin: 0 auto;
                padding-top: 2em;
                text-align: center;
            }
            
            #audio {
                display: none;
            }
                
            #playbutton {
                width: 10em;
                height: 2em;
                font-size: inherit;
            }
            
        </style>

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
                    if (requestURL == '') return;
                    
                    var xhr = new XMLHttpRequest();
                    xhr.open('POST', 'sendalo.php', true);
                    xhr.responseType = 'arraybuffer';
                    xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');

                    xhr.onreadystatechange = function (ev) {
                        if (this.readyState === 4 && this.status >= 200 && this.status <= 400) {
                            downloadComplete(this.response);
                        }
                    };

                    xhr.send("url=" + encodeURI(requestURL));
                }
                
                var pb = document.getElementById('playbutton');
                pb.value = 'Please wait...';
                pb.disabled = true;
                document.getElementById('url').disabled = true;
                document.getElementById('upload').disabled = true;
                document.getElementById('format').disabled = true;
            }

            function downloadComplete(what) {
                var dt = new Uint8Array(what);
                if (!dt || dt.length !== 143360) {
                    displayError();
                    return;
                }
                
                FS.writeFile('/tmp/c2t.dsk', dt);
                var opts = document.getElementById('format').checked ? '-8' : '-n8';
                Module.callMain([opts, '/tmp/c2t.dsk', '/tmp/c2t.wav']);
                fd = FS.readFile('/tmp/c2t.wav', {encoding: 'binary'});
                b = new Blob([fd], { type: 'audio/wav' });
                u = URL.createObjectURL(b);
                audio = document.getElementById('audio');
                source = document.getElementById('source');
                source.src = u;
                
                document.getElementById('playbutton').style.display = 'none';
                audio.style.display = 'block';
                audio.load();
                audio.play();
                
                
            }
            
            function displayError() {
                alert('Error: only 140K DOS-order images are supported for now. That doesn\'t look like one.');

                var pb = document.getElementById('playbutton');
                pb.value = 'Play!';
                pb.disabled = false;
                document.getElementById('url').disabled = false;
                document.getElementById('upload').disabled = false;
                document.getElementById('format').disabled = false;
            }
            
            function resetFile() {
                document.getElementById('fc').innerHTML = '<input type="file" onchange="resetURL()" id="upload" />';
                document.getElementById('url').placeholder = 'https://...';
            }
            
            function resetURL() {
                var txt = document.getElementById('url');
                txt.value='';
                txt.placeholder = '-- uploaded file --';
            }
        </script>
    </head>

    <body>
        <header>
            <h1>Sendalo!</h1>
            <h2>Insert image URL or upload file</h2>
        </header>

        <main>
            <form onsubmit="return false;">
                <input type="text" onkeypress="resetFile()" placeholder="https://..." id="url"/><br/>
                <div id="fc"><input type="file" onchange="resetURL()" id="upload" /></div><br/>
                <input id="format" type="checkbox"><label for="format"><small>Format disk?</small></label><br/><br/>
                <input type="button" id="playbutton" value="Play!" onclick="downloadFile()"/><br/>
            </form>
            
            <div id="audiopad">
                <audio controls="controls" id="audio">
                    <source id="source" src="" type="audio/wav" />
                </audio>
            </div>

            <p id="w"><a href="#" onclick="document.getElementById('expl').style.display='block'">
                <small>What's this?</small>
            </a></p>
            <div id="expl">
            <p>
                Sendalo is a web/mobile interface to an emscripten build of the excellent
                <a href="https://github.com/datajerk/c2t">c2t</a> tool by
                <a href="https://github.com/datajerk">datajerk</a>.
            </p>
            <p>
                c2t is a really clever program that allows transferring disk images to
                a running Apple II (among other things).
            </p>

            <h3>Why do I think this is useful?</h3>
            <p><ul>
                <li>The ASCII Express site is fun and a great idea, but it has
                    limited selection.</li>

                <li>ADTPro is fantastic! But you need a running modern PC, and
                    some means of bidirectional communication to make it work.
                    Ethernet cards are expensive, serial not readily available
                    and audio mic input jacks are becoming difficult to find on
                    modern laptops. And there is no mobile version.</li>

                <li>c2t will work with just a simplex link, so all you need is an
                    audio cable and there you go! But you still need another
                    computer and typing commands in the terminal.</li>

                <li>Finally, with this frontend you can unleash the power of c2t
                    directly on your mobile device, with just an audio cable
                    and no PC. Just paste the .dsk image URL from your favorite
                    web archive, or upload your own, and the disk will be streamed
                    over. Also nice on computers if you don’t want to download
                    executables or type commands.</li>
            </ul></p>

            <p>
                c2t can do a lot more than this, don’t forget to check the official
                project page on GitHub to learn more.
            </p>
            </div>
        </main>

        <footer>
            <p>
                Sendalo: &copy; 2020 Federico Santandrea<br/>
                <a href="mailto:sntfrc@outlook.it">sntfrc@outlook.it</a><br/><br/>
                c2t: &copy; 2017 Egan Ford &lt;datajerk@gmail.com&gt;<br/>
                See <a href="https://raw.githubusercontent.com/datajerk/c2t/master/LICENSE">
                LICENSE</a>.
            </p>
        </footer>

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

        {{{ SCRIPT }}}
    </body>
</html>

