.PHONY: install

install:
   	pixlet || curl -LO https://github.com/tidbyt/pixlet/releases/download/v0.24.0/pixlet_0.24.0_linux_arm64.tar.gz && mv pixlet_0.24.0_linux_arm64.tar.gz /tmp/. && tar -xvf /tmp/pixlet_0.24.0_linux_arm64.tar.gz && chmod +x chmod +x /tmp/pixlet && sudo mv pixlet /usr/local/bin/.

.PHONY: build

build:
	docker build -t vivster7/pixlet-muni:amd-full-2 --platform linux/amd64 .
	
.PHONY: run

run:
	pixlet render pixlet-muni.star api_key="1" api_key="2"

# .PHONY: deploy
# https://app.airplane.dev UI
