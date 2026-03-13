SHELL   := /bin/zsh
SCHEME  := METIME
SIM     := platform=iOS Simulator,name=iPhone 15
XBUILD  := xcodebuild -project METIME.xcodeproj -scheme $(SCHEME) -sdk iphonesimulator \
            -destination '$(SIM)' CODE_SIGNING_ALLOWED=NO

.PHONY: setup generate build open test test-unit test-ui

# ── Bootstrap ────────────────────────────────────────────────────────────────
setup:
	brew install xcodegen || true
	$(MAKE) generate

generate:
	xcodegen generate

# ── Build ─────────────────────────────────────────────────────────────────────
build:
	$(XBUILD) build

# ── Open ──────────────────────────────────────────────────────────────────────
open:
	open METIME.xcodeproj

# ── Test ──────────────────────────────────────────────────────────────────────
## Run all tests (unit + UI)
test:
	$(MAKE) test-unit
	$(MAKE) test-ui

## Run only unit tests
test-unit:
	xcodebuild test -project METIME.xcodeproj -scheme METIMETests \
	  -sdk iphonesimulator -destination '$(SIM)' CODE_SIGNING_ALLOWED=NO

## Run only UI tests
test-ui:
	xcodebuild test -project METIME.xcodeproj -scheme METIMEUITests \
	  -sdk iphonesimulator -destination '$(SIM)' CODE_SIGNING_ALLOWED=NO
