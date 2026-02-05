import database.{type Table}
import gleam/erlang/atom
import todo_api/board.{type Board}
import todo_api/task.{type Task}
import todo_api/column.{type Column}

pub type Database {
  Database(
    boards: Table(Board),
    columns: Table(Column),
    tasks: Table(Task),
  )
}

pub fn get_database() -> Database {
  let assert Ok(board_table) =
    atom.create("tb_boards")
    |> database.create_table(board.decoder())

  let assert Ok(column_table) =
    atom.create("tb_columns")
    |> database.create_table(column.decoder())

  let assert Ok(card_table) =
    atom.create("tb_tasks")
    |> database.create_table(task.decoder())

  Database(board_table, column_table, card_table)
}
