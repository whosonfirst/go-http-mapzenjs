package http

import (
	gohttp "net/http"
)

func MapzenJSHandler() (gohttp.Handler, error) {

	fs := assetFS()
	return gohttp.FileServer(fs), nil
}
