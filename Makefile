BUILDDIR ?= $(CURDIR)/build

all: install

$(BUILDDIR)/:
	mkdir -p $@

BUILD_TARGETS := build install
build: $(BUILDDIR)/
build: BUILD_ARGS=-o=$(BUILDDIR)

$(BUILD_TARGETS):
	go $@ -mod=readonly $(BUILD_FLAGS) $(BUILD_ARGS) ./...

test:
	go test ./...

clean:
	rm -rf $(BUILDDIR)/

.PHONY: all $(BUILD_TARGETS) clean

lint:
	golangci-lint run --tests=false
	find . -name '*.go' -type f -not -path "*.git*" | xargs gofmt -d -s

format:
	find . -name '*.go' -type f -not -path "*.git*" | xargs gofmt -w -s
	find . -name '*.go' -type f -not -path "*.git*" | xargs goimports -w -local github.com/
