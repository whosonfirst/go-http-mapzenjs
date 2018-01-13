# go-mapzen-js

Go middleware package for mapzen.js
 
## Install

You will need to have both `Go` (specifically a version of Go more recent than 1.6 so let's just assume you need [Go 1.8](https://golang.org/dl/) or higher) and the `make` programs installed on your computer. Assuming you do just type:

```
make bin
```

All of this package's dependencies are bundled with the code in the `vendor` directory.

## Handlers

### MapzenJSHandler(http.Handler, mapzenjs.MapzenJSOptions) (http.Handler, error)

This handler will optionally modify the output of the `your_handler http.Handler` as follows:

* Append the relevant [mapzen.js](https://mapzen.com/documentation/mapzen-js/) `script` and `link` elements to the `head` element.
* Append a `data-mapzen-api-key` attribute (and value) to the `body` element.

```
import (
	"github.com/whosonfirst/go-http-mapzenjs"
	"net/http"
)

func main(){

	opts := mapzenjs.DefaultMapzenJSOptions()
	opts.APIKey = "mapzen-1a2b3c"

	www_handler := YourDefaultWWWHandler()
	
	mapzenjs_handler, _ := mapzenjs.MapzenJSHandler(www_handler, opts)

	mux := http.NewServeMux()
	mux.Handle("/", mapzenjs_handler)
```

_Note that error handling has been removed for the sake of brevity._

#### MapzenJSOptions

The definition for `MapzenJSOptions` looks like this:

```
type MapzenJSOptions struct {
	AppendAPIKey bool
	AppendJS     bool
	AppendCSS    bool
	APIKey       string
	JS           []string
	CSS          []string
}
```

Default `MapzenJSOptions` are:

```
	opts := MapzenJSOptions{
		AppendAPIKey: true,
		AppendJS:     true,
		AppendCSS:    true,
		APIKey:       "mapzen-xxxxxx",
		JS:           []string{"/javascript/mapzen.min.js"},
		CSS:          []string{"/css/mapzen.js.css"},
	}
```

### MapzenJSAssetsHandler() (http.Handler, error)

The handler will serve [mapzen.js](https://mapzen.com/documentation/mapzen-js/) and [tangram.js](https://github.com/tangrams/tangram) related assets which have been bundled with this package.

```
import (
	"github.com/whosonfirst/go-http-mapzenjs"
	"net/http"
)

func main(){

	mapzenjs_assets_handler, _ := mapzen.MapzenJSAssetsHandler()

	mux := http.NewServeMux()

	mux.Handle("/javascript/mapzen.js", mapzenjs_handler)
	mux.Handle("/javascript/mapzen.min.js", mapzenjs_handler)
	mux.Handle("/javascript/tangram.js", mapzenjs_handler)	
	mux.Handle("/javascript/tangram.min.js", mapzenjs_handler)
	mux.Handle("/css/mapzen.js.css", mapzenjs_handler)
	mux.Handle("/tangram/refill-style.zip", mapzenjs_handler)

}
```

You can update the various `mapzen.js` and `tangram.js` assets manually by invoking the `build` target in the included [Makefile](Makefile).

#### Styles

Currently the following styles are bundled with this package:

* [refill](https://tangrams.github.io/refill-style/)
* [walkabout](https://tangrams.github.io/walkabout-style/)

## See also 

* https://mapzen.com/documentation/mapzen-js/
* https://github.com/tangrams/tangram