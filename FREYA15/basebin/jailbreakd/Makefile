TARGET = jailbreakd

CC = clang++

CFLAGS = -Wall -std=c++11 -framework Foundation -framework CoreServices -framework Security -framework IOKit -framework UIKit -I./src/_shared -I./src -isysroot $(shell xcrun --sdk iphoneos --show-sdk-path) -arch arm64 -miphoneos-version-min=15.0 -fobjc-arc -Wno-nullability-completeness-on-arrays -O3
LDFLAGS = -lbsm 

CFLAGS += -DVERSION_COMMIT_COUNT='" "'
CFLAGS += -DVERSION_COMMIT_SHA='" "'

sign: $(TARGET)
	@ldid -Sentitlements.plist $<
	cp jailbreakd ../../binaries
	cp daemon.plist ../../binaries/kr.h4ck.jailbreakd.plist
	rm ../../binaries/binaries.tc
	trustcache create ../../binaries/binaries.tc ../../binaries
	find ../.. -type f -name '.*' -delete

$(TARGET): $(wildcard src/kernel/*.mm src/*.mm src/*.S src/machoparse/*.c src/common/*.cpp)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^


clean:
	@rm -f $(TARGET)
