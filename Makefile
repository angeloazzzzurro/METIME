SHELL   := /bin/zsh
SCHEME  := METIME
SIM     := platform=iOS Simulator,name=iPhone 17 Pro
XBUILD  := xcodebuild -project METIME.xcodeproj -scheme $(SCHEME) -sdk iphonesimulator \
            -destination '$(SIM)' CODE_SIGNING_ALLOWED=NO

.PHONY: setup generate build open preview test test-unit test-ui lint lint-fix

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

preview:
	open WebPreview/index.html

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

# ── Lint ──────────────────────────────────────────────────────────────────────
## Analisi statica con SwiftLint (sicurezza: force_try, force_cast, force_unwrapping)
lint:
	swiftlint lint --config .swiftlint.yml

## Corregge automaticamente le violazioni correggibili
lint-fix:
	swiftlint lint --fix --config .swiftlint.yml
