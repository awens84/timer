.PHONY: setup generate build run install clean

# Install XcodeGen and generate project
setup:
	@which xcodegen > /dev/null 2>&1 || brew install xcodegen
	@echo "✅ XcodeGen is ready"

# Generate Xcode project from project.yml
generate: setup
	xcodegen generate
	@echo "✅ BoostTimer.xcodeproj generated"

# Build Release
build: generate
	xcodebuild \
		-project BoostTimer.xcodeproj \
		-scheme BoostTimer \
		-configuration Release \
		-derivedDataPath ./build \
		build
	@echo "✅ Build complete: ./build/Build/Products/Release/Boost Timer.app"

# Build Debug and run
run: generate
	xcodebuild \
		-project BoostTimer.xcodeproj \
		-scheme BoostTimer \
		-configuration Debug \
		-derivedDataPath ./build \
		build
	@open "./build/Build/Products/Debug/Boost Timer.app"

# Install to /Applications
install: build
	@cp -r "./build/Build/Products/Release/Boost Timer.app" /Applications/
	@echo "✅ Installed to /Applications/Boost Timer.app"

# Clean build artifacts
clean:
	rm -rf build/ DerivedData/
	rm -rf BoostTimer.xcodeproj
	@echo "✅ Cleaned"
