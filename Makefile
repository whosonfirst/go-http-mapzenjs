CWD=$(shell pwd)
GOPATH := $(CWD)

prep:
	if test -d pkg; then rm -rf pkg; fi

self:   prep rmdeps
	if test -d src; then rm -rf src; fi
	mkdir src
	cp -r vendor/* src/

rmdeps:
	if test -d src; then rm -rf src; fi 

deps:
	@GOPATH=$(GOPATH) go get -u "github.com/zendesk/go-bindata/"
	@GOPATH=$(GOPATH) go get -u "github.com/elazarl/go-bindata-assetfs/"
	@GOPATH=$(GOPATH) go get -u "golang.org/x/net/html"
	rm -rf src/github.com/zendesk/go-bindata/testdata

fmt:
	go fmt *.go

vendor-deps: rmdeps deps
	if test -d vendor; then rm -rf vendor; fi
	cp -r src vendor
	find vendor -name '.git' -print -type d -exec rm -rf {} +
	rm -rf src

build:
	@make maps
	@make assets

maps:
	@make wwwdirs
	@make mapzenjs
	@make tangram
	@make styles

assets:	self
	if test ! -d bin; then mkdir bin; fi
	@GOPATH=$(GOPATH) go build -o bin/go-bindata ./vendor/github.com/zendesk/go-bindata/go-bindata/
	@GOPATH=$(GOPATH) go build -o bin/go-bindata-assetfs vendor/github.com/elazarl/go-bindata-assetfs/go-bindata-assetfs/main.go
	rm -f www/*~ www/css/*~ www/javascript/*~ www/tangram/*~
	@PATH=$(PATH):$(CWD)/bin bin/go-bindata-assetfs -pkg mapzenjs www www/javascript www/css www/tangram
	mv bindata.go assets.go

wwwdirs:
	if test ! -d www/javascript; then mkdir www/javascript; fi
	if test ! -d www/css; then mkdir www/css; fi
	if test ! -d www/tangram; then mkdir www/tangram; fi

tangram:
	curl -s -o www/javascript/tangram.js https://www.nextzen.org/tangram/tangram.debug.js
	curl -s -o www/javascript/tangram.min.js https://www.nextzen.org/tangram/tangram.min.js

styles: refill walkabout

refill:
	curl -s -o www/tangram/refill-style.zip https://www.nextzen.org/carto/refill-style/10/refill-style.zip
	curl -s -o www/tangram/refill-style-themes-label.zip https://www.nextzen.org/carto/refill-style/10/themes/label-10.zip

walkabout:
	curl -s -o www/tangram/walkabout-style.zip https://www.nextzen.org/carto/refill-style/walkabout-style.zip

mapzenjs:
	@echo "waiting for nextzen.js..."
	# curl -s -o www/css/mapzen.js.css https://mapzen.com/js/mapzen.css
	# curl -s -o www/javascript/mapzen.js https://mapzen.com/js/mapzen.js
	# curl -s -o www/javascript/mapzen.min.js https://mapzen.com/js/mapzen.min.js

# http://leafletjs.com/download.html

leaflet:
	curl -s -o www/css/leaflet.css https://unpkg.com/leaflet@1.3.1/dist/leaflet.css
	@make sritest FILE=www/css/leaflet.css EXPECTED=Rksm5RenBEKSKFjgI3a41vrjkw4EVPlJ3+OiI65vTjIdo9brlAacEuKOiQ5OFh7cOI1bkDwLqdLw3Zg0cRJAAQ==
	curl -s -o www/javascript/leaflet.js https://unpkg.com/leaflet@1.3.1/dist/leaflet.js 
	@make sritest FILE=www/javascript/leaflet.js EXPECTED=/Nsx9X4HebavoBvEBuyp3I7od5tA0UzAxs+j83KgC8PU0kgB4XiK4Lfe4y4cgBtaRJQEIFCW+oC506aPT2L1zw==

# https://github.com/chrisgreg/sri-gen/blob/master/sri-gen.go

sritest:
	$(eval SRIHASH := $(shell shasum -b -a 512 $(FILE)  | xxd -r -p | base64))
	if test "$(SRIHASH)" != "$(EXPECTED)"; then echo "$(FILE) has unexpected SRI hash"; exit 1; fi
	# @echo "$(FILE) has expected SRI hash"