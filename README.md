# go-mapzen-js



## Install

You will need to have both `Go` (specifically a version of Go more recent than 1.6 so let's just assume you need [Go 1.8](https://golang.org/dl/) or higher) and the `make` programs installed on your computer. Assuming you do just type:

```
make bin
```

All of this package's dependencies are bundled with the code in the `vendor` directory.

## Important

Too soon. Move along.

## Example

### MapzenJSHandler() (gohttp.Handler, error)

```
import (
	mapzen_http "github.com/whosonfirst/go-mapzen-js/http"
	go_http "net/http"
)

func main(){

	mapzenjs_handler, _ := mapzen_http.MapzenJSHandler()

	mux := go_http.NewServeMux()

	mux.Handle("/javascript/mapzen.js", mapzenjs_handler)
	mux.Handle("/javascript/mapzen.min.js", mapzenjs_handler)
	mux.Handle("/javascript/tangram.js", mapzenjs_handler)	
	mux.Handle("/javascript/tangram.min.js", mapzenjs_handler)
	mux.Handle("/css/mapzen.js.css", mapzenjs_handler)
	mux.Handle("/tangram/refill-style.zip", mapzenjs_handler)

}
```

### MapzenAPIKeyHandler(next gohttp.Handler, fs gohttp.FileSystem, api_key string) (gohttp.Handler, error)

This will insert to value of `api_key` in to the `data-mapzen-api-key` attribute of the body element for all HTML pages.

```
import (
	mapzen_http "github.com/whosonfirst/go-mapzen-js/http"
	go_http "net/http"
)

func main(){

     	api_key := "mapzen-xxxxxxx"
	
	fs := go_http.Dir("/usr/local/www")
	www_handler := go_http.FileServer(fs)
	
        key_handler, _ := mapzen_http.MapzenAPIKeyHandler(www_handler, fs, api_key)

	mux := go_http.NewServeMux()
        mux.Handle("/", key_handler)
}
```

It's gets a little more involved if you're trying to use the `MapzenAPIKeyHandler` with an `assetfs.AssetFS` derived file system, mostly because the generated code (containing your assets) doesn't export a public function for the filesystem itself.

So, you'll need to do something like this:

* Assume that we're going to create a local `http` namespace in our package
* Export your `assetfs.AssetFS` derived file system to the `http` namespace
* Create a `www.go` package, also in the `http` namespace thus allowing you to invoke the `assetFS()` function

For example:

```
package http

import (
        go_http "net/http"
)

func WWWFileSystem() go_http.FileSystem {
     return assetFS()
}

func WWWHandler() (go_http.Handler, error) {

        fs := assetFS()
	return go_http.FileServer(fs), nil
}
```

And then you would invoke it all, like this:

```
import (
	my_http "example.com/my/http"
	mapzen_http "github.com/whosonfirst/go-mapzen-js/http"
	go_http "net/http"
	
)

func main(){

	api_key := "mapzen-xxxxxx"
	
        www_handler, _ := my_http.WWWHandler()
        fs := my_http.WWWFileSystem()

        key_handler, _ := mapzen_http.MapzenAPIKeyHandler(www_handler, fs,*api_key)

	mux := go_http.NewServeMux()
        mux.Handle("/", key_handler)
}
```	
