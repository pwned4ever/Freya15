TARGET = launchdhook.dylib
CC = clang

CFLAGS = -framework Foundation -framework CoreServices -framework Security -framework IOKit -I./src/_shared -I./src -isysroot $(shell xcrun --sdk iphoneos --show-sdk-path) -arch arm64 -miphoneos-version-min=15.0 -fobjc-arc -O2
LDFLAGS = -dynamiclib -rpath @loader_path/fallback  -L./src/_shared -lbsm -lellekit

sign: $(TARGET)
	@ldid -S $^
	cp launchdhook.dylib ../../binaries
	rm ../../binaries/binaries.tc
	trustcache create ../../binaries/binaries.tc ../../binaries
	find ../.. -type f -name '.*' -delete

$(TARGET): $(wildcard src/*.m ../systemhook/src/common.c ../systemhook/src/envbuf.c)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

clean:
	@rm -f $(TARGET)