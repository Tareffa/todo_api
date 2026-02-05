import database
import gleam/json
import gleam/result
import gleam/string
import todo_api/board
import todo_api/db

// ============================================================================
// BOARD TESTS
// ============================================================================

pub fn to_json_test() {
  let test_board = board.Board("Test Board")
  let json_result = board.to_json(test_board, "board-1")

  let json_str = json.to_string(json_result)

  assert json_str != ""
  assert string.contains(json_str, "\"id\":\"board-1\"")
  assert string.contains(json_str, "\"name\":\"Test Board\"")
}

pub fn decoder_test() {
  let test_board = board.Board("Test Board")
  assert test_board.name == "Test Board"
}

pub fn new_insert_test() {
  let db = db.get_database()
  let test_board = board.Board("New Board")

  let assert Ok(id) = {
    use transac <- database.transaction(db.boards)
    let assert Ok(id) = database.insert(transac, test_board)
    id
  }

  assert id != ""
}

pub fn update_test() {
  let db = db.get_database()
  let original_board = board.Board("Original")

  let assert Ok(id) = {
    use transac <- database.transaction(db.boards)
    let assert Ok(id) = database.insert(transac, original_board)
    id
  }

  let updated_board = board.Board("Updated")
  let update_result = {
    use transac <- database.transaction(db.boards)
    database.update(transac, id, updated_board)
  }

  assert result.is_ok(update_result)
}

pub fn delete_test() {
  let db = db.get_database()
  let test_board = board.Board("To Delete")

  let assert Ok(id) = {
    use transac <- database.transaction(db.boards)
    let assert Ok(id) = database.insert(transac, test_board)
    id
  }

  let delete_result = {
    use transac <- database.transaction(db.boards)
    database.delete(transac, id)
  }

  assert result.is_ok(delete_result)
}
