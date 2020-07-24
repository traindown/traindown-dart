require "rack/contrib/try_static"
require "rack/contrib/not_found"

use Rack::TryStatic, {
  root: "public",
  header_rules: [
    [:all, {
      'Cache-Control' => 'no-cache no-store',
    }]
  ],
  urls: %w[/],
  try: %w[.html index.html /index.html .css main.css /main.css]
}

run Rack::NotFound.new("public/404.html")
