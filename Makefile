# lint is memory and CPU intensive, so we can limit on CI to mitigate OOM
LINT_GOGC?=off
LINT_CONCURRENCY?=8
# Set timeout for linter
LINT_DEADLINE?=1m0s

vendor: Gopkg.toml
	dep ensure -v -vendor-only

.PHONY: windows-build
windows-build:
	GOOS=windows go build ./...

.PHONY: linux-build
linux-build:
	GOOS=linux go build ./...

.PHONY: darwin-build
darwin-build:
	GOOS=darwin go build ./...

.PHONY: build
build: linux-build windows-build darwin-build

.PHONY: lint
lint: vendor build
	# golangci-lint does not do a good job of formatting imports
	goimports -local github.com/kubework/pkg -w `find . ! -path './vendor/*' -type f -name '*.go'`
	GOGC=$(LINT_GOGC) golangci-lint run --fix --verbose --concurrency $(LINT_CONCURRENCY) --deadline $(LINT_DEADLINE)

.PHONY: test
test: lint
	go test -v -covermode=count -coverprofile=coverage.out ./...
