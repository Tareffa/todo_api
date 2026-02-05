import database
import gleam/dynamic/decode
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/json
import mist.{type Connection}
import todo_api/web

pub type Board {
  Board(name: String)
}

pub fn decoder() {
  use name <- database.field(0, decode.string)
  decode.success(Board(name))
}

pub fn to_json(board: Board, id: String) {
  json.object([
    #("id", json.string(id)),
    #("name", json.string(board.name)),
  ])
}

fn from_json(
  req: Request(Connection),
  callback: fn(Board) -> response.Response(mist.ResponseData),
) {
  use json_body <- web.get_body(req)
  let decoder = {
    use name <- decode.field("name", decode.string)
    decode.success(Board(name))
  }
  case json.parse(from: json_body, using: decoder) {
    Ok(board) -> callback(board)
    Error(_) -> web.bad_request()
  }
}

pub fn get_all(table: database.Table(Board)) {
  let assert Ok(json_response) = {
    use transac <- database.transaction(table)
    use value <- database.select(transac)
    case value {
      #(id, board) -> database.Continue(to_json(board, id))
    }
  }
  json.array(json_response, of: fn(x) { x })
  |> web.json
}

pub fn new(req: request.Request(mist.Connection), table: database.Table(Board)) {
  use board <- from_json(req)
  let assert Ok(id) = {
    use transac <- database.transaction(table)
    let assert Ok(id) = database.insert(transac, board)
    id
  }
  json.object([
    #("id", json.string(id)),
    #("name", json.string(board.name)),
  ])
  |> web.json
}

pub fn update(req: web.MistRequest, table: database.Table(Board), id: String) {
  use board <- from_json(req)
  let query = {
    use transac <- database.transaction(table)
    database.update(transac, id, board)
  }
  case query {
    Ok(_) -> web.json(to_json(board, id))
    Error(_) -> web.not_found()
  }
}

pub fn delete(table: database.Table(Board), id: String) {
  let delete_result = {
    use transac <- database.transaction(table)
    database.delete(transac, id)
  }
  case delete_result {
    Ok(_) -> web.json(json.object([#("status", json.string("ok"))]))
    Error(_) -> web.not_found()
  }
}
