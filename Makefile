.PHONY: install

install:
   	pixlet || curl -LO https://github.com/tidbyt/pixlet/releases/download/v0.24.0/pixlet_0.24.0_linux_arm64.tar.gz && tar -xvf pixlet_0.24.0_linux_arm64.tar.gz && chmod +x pixlet && sudo install pixlet /usr/local/bin/

.PHONY: build

build:
	docker build -t vivster7/pixlet-muni:amd-full-2 --platform linux/amd64 .
	
.PHONY: run

run:
	pixlet render pixlet-muni.star api_key="" api_key_2=""

.PHONY: push
	run
	pixlet push hopelessly-fast-exuberant-tuatara-454 pixlet-muni.webp -t "<tidbyt-api-token>"


# .PHONY: deploy
# https://app.airplane.dev UI
