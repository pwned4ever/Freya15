build_release: | clean pack_release
build_debug: | clean pack_debug
.PHONY: build_release

VERSION=101.0
RELEASE_CFLAGS = -DNDEBUG -Os -std=gnu11 -flto=thin
DEBUG_CFLAGS = -DNDEBUG -g -O0 -std=gnu11
CC = xcrun clang -arch arm64 -target arm64-apple-darwin -miphoneos-version-min=11.0 -miphoneos-version-min=12.0 -isysroot $(shell xcrun --sdk iphoneos --show-sdk-path) -Wl,-export_dynamic -shared -Iinclude -Isrc -Llib -framework Foundation -framework IOKit

release:
	$(CC) $(RELEASE_CFLAGS) $(wildcard src/*.m) -DVERSION=$(VERSION) -o libkrw-kfund.dylib
	ldid -S libkrw-kfund.dylib
debug:
	$(CC) $(DEBUG_CFLAGS) $(wildcard src/*.m) -DVERSION=$(VERSION) -o libkrw-kfund.dylib
	ldid -S libkrw-kfund.dylib

pack:
	rm -rf .tmp || true
	mkdir .tmp
	cd .tmp && \
	mkdir -p libkrw0-kfund/DEBIAN && \
	mkdir -p libkrw0-kfund/var/jb/usr/lib/libkrw/ && \
	pwd && \
	touch libkrw0-kfund/DEBIAN/control && \
	cp ../libkrw-kfund.dylib libkrw0-kfund/var/jb/usr/lib/libkrw/ && \
	( echo 'Package: libkrw0-kfund'; \
	  echo 'Name: libkrw0-kfund'; \
	  echo 'Author: wh1te4ever'; \
	  echo 'Maintainer: wh1te4ever'; \
	  echo 'Architecture: iphoneos-arm64'; \
	  echo 'Version: $(VERSION)'; \
	  echo 'Provides: libkrw0-plugin'; \
	  echo 'Priority: optional'; \
	  echo 'Section: Development'; \
	  echo 'Description: Plugin for libkrw interacing with kfund-arm64 jailbreakd'; \
	  echo 'Homepage: https://github.com/wh1te4ever/kfund/tree/arm64'; \
	) > libkrw0-kfund/DEBIAN/control && \
	dpkg-deb -Zzstd -b libkrw0-kfund ../libkrw0-kfund.deb && \
	rm -rf .tmp || true

pack_release: release
	$(MAKE) pack && \
	cp libkrw0-kfund.deb ../../debs

pack_debug: debug
	$(MAKE) pack

clean:
	rm -rf $(wildcard libkrw*.dylib)
