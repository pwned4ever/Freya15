TARGET = jbinit

CC = clang

CFLAGS = -framework Foundation -framework CoreServices -framework IOKit -I./src/_shared -isysroot $(shell xcrun --sdk iphoneos --show-sdk-path) -arch arm64 -miphoneos-version-min=15.0
LDFLAGS = -lbsm 

sign: $(TARGET)
	@ldid -Sentitlements.plist -Icom.apple.jbinit $<
	cp jbinit ../../binaries
	rm ../../binaries/binaries.tc
	trustcache create ../../binaries/binaries.tc ../../binaries
	find ../.. -type f -name '.*' -delete

$(TARGET): $(wildcard src/*.m)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

clean:
	@rm -f $(TARGET)