TARGET = systemhook.dylib
CC = clang

CFLAGS = -I../_shared -I./src -isysroot $(shell xcrun --sdk iphoneos --show-sdk-path) -arch arm64 -miphoneos-version-min=15.0 -Wno-deprecated-declarations -Os -moutline -framework Foundation
LDFLAGS = -dynamiclib

sign: $(TARGET)
	@ldid -S $^

$(TARGET): $(wildcard src/*.m src/*.c)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	@ldid -S systemhook.dylib
	cp systemhook.dylib ../../binaries
	rm ../../binaries/binaries.tc
	trustcache create ../../binaries/binaries.tc ../../binaries
	find ../.. -type f -name '.*' -delete

clean:
	@rm -f $(TARGET)