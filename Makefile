.PHONY: all build clean distclean

# Configuration
SWIFT = swift
BUILD_DIR = .build
RELEASE_DIR = $(BUILD_DIR)/release
DEBUG_DIR = $(BUILD_DIR)/debug
BINARY_NAME = bbg

# Detect Linux
UNAME_S := $(shell uname -s)
RELEASE_FLAGS := -c release
ifeq ($(UNAME_S),Linux)
	RELEASE_FLAGS += --static-swift-stdlib
endif

# Default target
all: build

# Build the project
build:
	$(SWIFT) build
	@echo "Build complete. Binary available at: $(DEBUG_DIR)/$(BINARY_NAME)"

# Build for release
release:
	$(SWIFT) build $(RELEASE_FLAGS)
	@echo "Release build complete. Binary available at: $(RELEASE_DIR)/$(BINARY_NAME)"

# Clean build artifacts
clean:
	$(SWIFT) package clean

distclean:
	rm -rf $(BUILD_DIR)
