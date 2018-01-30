BUILD_DIR        = "${GOPATH}/src/github.com/eriknelson/hydro/build"
SOURCE_DIRS      = cmd pkg
SOURCES          := $(shell find . -name '*.go' -not -path "*/vendor/*")
PACKAGES         := $(shell go list ./pkg/...)
.DEFAULT_GOAL    := hydrodemo

hydrodemo: $(SOURCES) ## Build the broker
	go build -i -ldflags="-s -w" ./cmd/hydrodemo

build: hydrodemo## Build binary from source
	@echo > /dev/null

lint: ## Run golint
	@golint -set_exit_status $(addsuffix /... , $(SOURCE_DIRS))

fmt: ## Run go fmt
	@gofmt -d $(SOURCES)

fmtcheck: ## Check go formatting
	@gofmt -l $(SOURCES) | grep ".*\.go"; if [ "$$?" = "0" ]; then exit 1; fi

test: ## Run unit tests
	@go test -cover ./pkg/...

vet: ## Run go vet
	@go tool vet ./cmd ./pkg

check: fmtcheck vet lint build test ## Pre-flight checks before creating PR

run: broker
	@./hydrodemo

clean: ## Clean up your working environment
	@rm -f hydrodemo
	@rm -f build/hydrodemo

.PHONY: run lint build fmt fmtcheck test vet
