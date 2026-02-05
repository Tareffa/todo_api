import database
import gleam/json
import gleam/result
import gleam/string
import todo_api/column
import todo_api/db

// ============================================================================
// COLUMN TESTS
// ============================================================================

pub fn to_json_test() {
  let test_column = column.Column("A Fazer", 0, "board-1")
  let json_result = column.to_json(test_column, "column-1")

  let json_str = json.to_string(json_result)

  assert json_str != ""
  assert string.contains(json_str, "\"id\":\"column-1\"")
  assert string.contains(json_str, "\"name\":\"A Fazer\"")
  assert string.contains(json_str, "\"position\":0")
  assert string.contains(json_str, "\"boardId\":\"board-1\"")
}

pub fn decoder_test() {
  let test_column = column.Column("Test Column", 1, "board-1")
  assert test_column.name == "Test Column"
  assert test_column.position == 1
  assert test_column.board_id == "board-1"
}

pub fn new_insert_test() {
  let db = db.get_database()
  let test_column = column.Column("New Column", 0, "board-1")

  let assert Ok(id) = {
    use transac <- database.transaction(db.columns)
    let assert Ok(id) = database.insert(transac, test_column)
    id
  }

  assert id != ""
}

pub fn update_test() {
  let db = db.get_database()
  let original_column = column.Column("Original", 0, "board-1")

  let assert Ok(id) = {
    use transac <- database.transaction(db.columns)
    let assert Ok(id) = database.insert(transac, original_column)
    id
  }

  let updated_column = column.Column("Updated", 1, "board-1")
  let update_result = {
    use transac <- database.transaction(db.columns)
    database.update(transac, id, updated_column)
  }

  assert result.is_ok(update_result)
}

pub fn delete_test() {
  let db = db.get_database()
  let test_column = column.Column("To Delete", 0, "board-1")

  let assert Ok(id) = {
    use transac <- database.transaction(db.columns)
    let assert Ok(id) = database.insert(transac, test_column)
    id
  }

  let delete_result = {
    use transac <- database.transaction(db.columns)
    database.delete(transac, id)
  }

  assert result.is_ok(delete_result)
}

pub fn position_ordering_test() {
  let col1 = column.Column("First", 0, "board-1")
  let col2 = column.Column("Second", 1, "board-1")
  let col3 = column.Column("Third", 2, "board-1")

  assert col1.position < col2.position
  assert col2.position < col3.position
  assert col3.position > col1.position
}
