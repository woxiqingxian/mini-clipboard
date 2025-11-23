PROJECT=MiniClipboard.xcodeproj
SCHEME=mini-clipboard
CONFIG=Debug
DERIVED=.build

.PHONY: build clean

build:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration $(CONFIG) -derivedDataPath $(DERIVED) CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

clean:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration $(CONFIG) -derivedDataPath $(DERIVED) clean