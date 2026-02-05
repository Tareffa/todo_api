import database
import gleam/dynamic/decode
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/json
import mist.{type Connection}
import todo_api/web

pub type Task {
  Task(
    name: String,
    position: Int,
    created_at: String,
    due_date: String,
    completed: Bool,
    tags: List(String),
    column_id: String,
  )
}

pub fn decoder() {
  use name <- database.field(0, decode.string)
  use position <- database.field(1, decode.int)
  use created_at <- database.field(2, decode.string)
  use due_date <- database.field(3, decode.string)
  use completed <- database.field(4, decode.bool)
  use tags <- database.field(5, decode.list(decode.string))
  use column_id <- database.field(6, decode.string)
  decode.success(Task(
    name,
    position,
    created_at,
    due_date,
    completed,
    tags,
    column_id,
  ))
}

pub fn to_json(task: Task, id: String) {
  json.object([
    #("id", json.string(id)),
    #("name", json.string(task.name)),
    #("position", json.int(task.position)),
    #("createdAt", json.string(task.created_at)),
    #("dueDate", json.string(task.due_date)),
    #("completed", json.bool(task.completed)),
    #("tags", json.array(task.tags, of: json.string)),
    #("columnId", json.string(task.column_id)),
  ])
}

fn from_json(
  req: Request(Connection),
  callback: fn(Task) -> response.Response(mist.ResponseData),
) {
  use json_body <- web.get_body(req)
  let decoder = {
    use name <- decode.field("name", decode.string)
    use position <- decode.field("position", decode.int)
    use created_at <- decode.field("createdAt", decode.string)
    use due_date <- decode.field("dueDate", decode.string)
    use completed <- decode.field("completed", decode.bool)
    use tags <- decode.field("tags", decode.list(decode.string))
    use column_id <- decode.field("columnId", decode.string)
    decode.success(Task(
      name,
      position,
      created_at,
      due_date,
      completed,
      tags,
      column_id,
    ))
  }
  case json.parse(from: json_body, using: decoder) {
    Ok(task) -> callback(task)
    Error(_) -> web.bad_request()
  }
}

pub fn get_by_column_id(table: database.Table(Task), column_id: String) {
  let assert Ok(result_set) = {
    use transac <- database.transaction(table)
    use value <- database.select(transac)
    case value {
      #(id, Task(name, position, created_at, due_date, completed, tags, c_id))
        if c_id == column_id
      ->
        database.Continue(to_json(
          Task(name, position, created_at, due_date, completed, tags, c_id),
          id,
        ))
      _ -> database.Skip
    }
  }
  json.array(result_set, of: fn(x) { x })
  |> web.json
}

pub fn new(
  req: request.Request(mist.Connection),
  table: database.Table(Task),
  column_id: String,
) {
  use task <- from_json(req)
  let task_with_column =
    Task(
      task.name,
      task.position,
      task.created_at,
      task.due_date,
      task.completed,
      task.tags,
      column_id,
    )
  let assert Ok(id) = {
    use transac <- database.transaction(table)
    let assert Ok(id) = database.insert(transac, task_with_column)
    id
  }
  to_json(task_with_column, id)
  |> web.json
}

pub fn update(req: web.MistRequest, table: database.Table(Task), id: String) {
  use task <- from_json(req)
  let query = {
    use transac <- database.transaction(table)
    database.update(transac, id, task)
  }
  case query {
    Ok(_) -> web.json(to_json(task, id))
    Error(_) -> web.not_found()
  }
}

pub fn delete(table: database.Table(Task), id: String) {
  let delete_result = {
    use transac <- database.transaction(table)
    database.delete(transac, id)
  }
  case delete_result {
    Ok(_) -> web.json(json.object([#("status", json.string("ok"))]))
    Error(_) -> web.not_found()
  }
}
