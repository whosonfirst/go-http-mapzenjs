package http

import (
	"bytes"
	"golang.org/x/net/html"
	"io"
	"io/ioutil"
	_ "log"
	gohttp "net/http"
	"strings"
)

func MapzenAPIKeyHandler(next gohttp.Handler, fs gohttp.FileSystem, api_key string) (gohttp.Handler, error) {

	fn := func(rsp gohttp.ResponseWriter, req *gohttp.Request) {

		path := req.URL.Path

		if strings.HasSuffix(path, "/"){
			path = path + "index.html"
		}
		
		if !strings.HasSuffix(path, "index.html"){
			next.ServeHTTP(rsp, req)
			return
		}

		fh, err := fs.Open(path)

		if err != nil {
			gohttp.Error(rsp, err.Error(), gohttp.StatusInternalServerError)
			return
		}

		body, err := ioutil.ReadAll(fh)

		if err != nil {
			gohttp.Error(rsp, err.Error(), gohttp.StatusInternalServerError)
			return
		}

		reader := bytes.NewReader(body)
		doc, err := html.Parse(reader)

		if err != nil {
			gohttp.Error(rsp, err.Error(), gohttp.StatusInternalServerError)
			return
		}

		var f func(node *html.Node, writer io.Writer)

		f = func(n *html.Node, w io.Writer) {

			if n.Type == html.ElementNode && n.Data == "body" {

				api_key_ns := ""
				api_key_key := "data-mapzen-api-key"
				api_key_value := api_key

				api_key_attr := html.Attribute{api_key_ns, api_key_key, api_key_value}
				n.Attr = append(n.Attr, api_key_attr)
			}

			for c := n.FirstChild; c != nil; c = c.NextSibling {
				f(c, w)
			}
		}

		f(doc, rsp)

		html.Render(rsp, doc)
		return
	}

	return gohttp.HandlerFunc(fn), nil
}
