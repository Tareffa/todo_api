import envoy
import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/result
import mist
import todo_api/db
import todo_api/router

pub fn main() -> Nil {
  io.println("Starting server...")

  let port = get_port()

  let assert Ok(_) =
    router.handle_request(_, db.get_database())
    |> mist.new
    |> mist.bind("0.0.0.0")
    |> mist.port(port)
    |> mist.start

  io.println("Server started at port " <> int.to_string(port))

  process.sleep_forever()
}

fn get_port() {
  envoy.get("PORT")
  |> result.try(int.parse)
  |> result.unwrap(8080)
}
