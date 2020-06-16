all: obj/c2t-96h.so link addproxy

c2t:
	@if [ -z "${C2TDIR}" ]; then echo "Please set C2TDIR environment variable to the path of c2t source tree."; exit 1; fi
	cd ${C2TDIR}; make
	touch c2t

clean:
	rm -f c2t
	rm -rf bin/
	rm -rf obj/

obj/c2t-96h.so: c2t
	mkdir -p obj
	emcc -c -Wall -Wno-strict-aliasing -Wno-misleading-indentation -Wno-unused-value -Wno-unused-function -I${C2TDIR} -O3 -o obj/c2t-96h.so ${C2TDIR}/c2t-96h.c -lm

link:
	mkdir -p bin
	emcc --shell-file sendalo.html.tpl -s INVOKE_RUN=0 -s EXIT_RUNTIME=0 -s ALLOW_MEMORY_GROWTH=1 -s EXTRA_EXPORTED_RUNTIME_METHODS=['callMain'] -o bin/sendalo.html obj/c2t-96h.so

addproxy:
	head --bytes=-1 sendalo.php.tpl > bin/sendalo.php
	cat bin/sendalo.html >> bin/sendalo.php
#	rm bin/sendalo.html

test:
	cd bin; python3 -m http.server 65020

