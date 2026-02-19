import gleam/bit_array
import gleam/bytes_tree
import gleam/http
import gleam/http/request
import gleam/http/response.{type Response}
import gleam/int
import gleam/json
import gleam/list
import gleam/result
import gleam/string
import mist

pub type MistRequest =
  request.Request(mist.Connection)

pub fn default_headers(resp: Response(a)) {
  resp
  |> response.set_header("Access-Control-Allow-Headers", "*")
  |> response.set_header(
    "Access-Control-Allow-Methods",
    "GET,HEAD,PUT,PATCH,DELETE",
  )
  |> response.set_header("Access-Control-Allow-Origin", "*")
}

pub fn not_found() {
  let body = mist.Bytes(bytes_tree.from_string("Not found"))
  response.new(404)
  |> response.set_header("Content-Type", "text/plain")
  |> default_headers
  |> response.set_body(body)
}

pub fn method_not_allowed(allowed_methods: List(http.Method)) {
  let methods =
    list.map(allowed_methods, http.method_to_string)
    |> string.join(",")
    |> string.uppercase
  let body = mist.Bytes(bytes_tree.from_string("Method not allowed"))
  response.new(405)
  |> response.set_header("Content-Type", "text/plain")
  |> default_headers
  |> response.set_header("Allow", methods)
  |> response.set_header("Access-Control-Allow-Methods", methods)
  |> response.set_body(body)
}

pub fn bad_request() {
  let body = mist.Bytes(bytes_tree.from_string("Bad request"))
  response.new(400)
  |> response.set_header("Content-Type", "text/plain")
  |> default_headers
  |> response.set_body(body)
}

pub fn no_content() {
  let body = mist.Bytes(bytes_tree.from_string(""))
  response.new(204)
  |> default_headers
  |> response.set_body(body)
}

pub fn json(json_string: json.Json) {
  let body = mist.Bytes(bytes_tree.from_string(json.to_string(json_string)))
  response.new(200)
  |> response.set_header("Content-Type", "application/json")
  |> default_headers
  |> response.set_body(body)
}

pub fn get_body(
  req: request.Request(mist.Connection),
  callback: fn(String) -> Response(mist.ResponseData),
) {
  let content_length =
    request.get_header(req, "content-length")
    |> result.try(int.parse)
    |> result.unwrap(1024 * 1024 * 10)

  case mist.read_body(req, content_length) {
    Ok(n) ->
      case bit_array.to_string(n.body) {
        Ok(json_string) -> callback(json_string)
        Error(_) -> bad_request()
      }
    Error(_) -> bad_request()
  }
}
