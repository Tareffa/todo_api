import gleam/http
import gleam/http/request.{type Request}
import mist.{type Connection}
import todo_api/board
import todo_api/column
import todo_api/db.{type Database}
import todo_api/task
import todo_api/web

pub fn handle_request(req: Request(Connection), db: Database) {
  case request.path_segments(req), req.method {
    ["api", "v1", "board"], http.Get -> board.get_all(db.boards)
    ["api", "v1", "board"], http.Post -> board.new(req, db.boards)
    ["api", "v1", "board"], _ -> web.method_not_allowed([http.Get, http.Post])
    ["api", "v1", "board", board_id], http.Put ->
      board.update(req, db.boards, board_id)
    ["api", "v1", "board", board_id], http.Delete ->
      board.delete(db.boards, board_id)
    ["api", "v1", "board", _], _ ->
      web.method_not_allowed([http.Put, http.Delete, http.Post])

    ["api", "v1", "column", "from", board_id], http.Get ->
      column.get_by_board_id(db.columns, board_id)
    ["api", "v1", "column", "from", _], _ -> web.method_not_allowed([http.Get])
    ["api", "v1", "column"], http.Post -> column.new(req, db.columns)
    ["api", "v1", "column", column_id], http.Put ->
      column.update(req, db.columns, column_id)
    ["api", "v1", "column", column_id], http.Delete ->
      column.delete(db.columns, column_id)
    ["api", "v1", "column", _], _ ->
      web.method_not_allowed([http.Put, http.Delete, http.Post])

    ["api", "v1", "task", "from", column_id], http.Get ->
      task.get_by_column_id(db.tasks, column_id)
    ["api", "v1", "task", "from", _], _ -> web.method_not_allowed([http.Get])
    ["api", "v1", "task"], http.Post -> task.new(req, db.tasks)
    ["api", "v1", "task", task_id], http.Put ->
      task.update(req, db.tasks, task_id)
    ["api", "v1", "task", task_id], http.Delete ->
      task.delete(db.tasks, task_id)
    ["api", "v1", "task", _], _ ->
      web.method_not_allowed([http.Put, http.Delete, http.Post])

    _, _ -> web.not_found()
  }
}
