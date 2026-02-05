import database
import gleam/dynamic/decode
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/json
import mist.{type Connection}
import todo_api/web

pub type Column {
  Column(name: String, position: Int, board_id: String)
}

pub fn decoder() {
  use name <- database.field(0, decode.string)
  use position <- database.field(1, decode.int)
  use board_id <- database.field(2, decode.string)
  decode.success(Column(name, position, board_id))
}

pub fn to_json(column: Column, id: String) {
  json.object([
    #("id", json.string(id)),
    #("name", json.string(column.name)),
    #("position", json.int(column.position)),
    #("boardId", json.string(column.board_id)),
  ])
}

fn from_json(
  req: Request(Connection),
  callback: fn(Column) -> response.Response(mist.ResponseData),
) {
  use json_body <- web.get_body(req)
  let decoder = {
    use name <- decode.field("name", decode.string)
    use position <- decode.field("position", decode.int)
    use board_id <- decode.field("boardId", decode.string)
    decode.success(Column(name, position, board_id))
  }
  case json.parse(from: json_body, using: decoder) {
    Ok(column) -> callback(column)
    Error(_) -> web.bad_request()
  }
}

pub fn get_by_board_id(table: database.Table(Column), board_id: String) {
  let assert Ok(result_set) = {
    use transac <- database.transaction(table)
    use value <- database.select(transac)
    case value {
      #(id, Column(name, position, b_id)) if b_id == board_id ->
        database.Continue(to_json(Column(name, position, b_id), id))
      _ -> database.Skip
    }
  }
  json.array(result_set, of: fn(x) { x })
  |> web.json
}

pub fn new(req: request.Request(mist.Connection), table: database.Table(Column)) {
  use column <- from_json(req)
  let assert Ok(id) = {
    use transac <- database.transaction(table)
    let assert Ok(id) = database.insert(transac, column)
    id
  }
  to_json(column, id)
  |> web.json
}

pub fn update(req: web.MistRequest, table: database.Table(Column), id: String) {
  use column <- from_json(req)
  let query = {
    use transac <- database.transaction(table)
    database.update(transac, id, column)
  }
  case query {
    Ok(_) -> web.json(to_json(column, id))
    Error(_) -> web.not_found()
  }
}

pub fn delete(table: database.Table(Column), id: String) {
  let delete_result = {
    use transac <- database.transaction(table)
    database.delete(transac, id)
  }
  case delete_result {
    Ok(_) -> web.json(json.object([#("status", json.string("ok"))]))
    Error(_) -> web.not_found()
  }
}
