SHELL := /bin/zsh
.PHONY: setup generate build open

setup:
	brew install xcodegen || true
	$(MAKE) generate

generate:
	xcodegen generate

build:
	xcodebuild -project METIME.xcodeproj -scheme METIME -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' CODE_SIGNING_ALLOWED=NO build

open:
	open METIME.xcodeproj
