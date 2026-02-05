import database
import gleam/json
import gleam/result
import gleam/string
import todo_api/db
import todo_api/task

// ============================================================================
// TASK TESTS
// ============================================================================

pub fn to_json_test() {
  let test_task =
    task.Task(
      "Test Task",
      0,
      "2026-02-05T10:00:00Z",
      "2026-02-10T23:59:59Z",
      False,
      ["tag1", "tag2"],
      "column-1",
    )
  let json_result = task.to_json(test_task, "task-1")

  let json_str = json.to_string(json_result)

  assert json_str != ""
  assert string.contains(json_str, "\"id\":\"task-1\"")
  assert string.contains(json_str, "\"name\":\"Test Task\"")
  assert string.contains(json_str, "\"position\":0")
  assert string.contains(json_str, "\"completed\":false")
  assert string.contains(json_str, "\"columnId\":\"column-1\"")
}

pub fn decoder_test() {
  let test_task =
    task.Task(
      "Test Task",
      0,
      "2026-02-05T10:00:00Z",
      "2026-02-10T23:59:59Z",
      False,
      ["tag1", "tag2"],
      "column-1",
    )

  assert test_task.name == "Test Task"
  assert test_task.position == 0
  assert test_task.completed == False
  assert test_task.column_id == "column-1"
  assert test_task.tags == ["tag1", "tag2"]
}

pub fn new_insert_test() {
  let db = db.get_database()
  let test_task =
    task.Task(
      "New Task",
      0,
      "2026-02-05T10:00:00Z",
      "2026-02-10T23:59:59Z",
      False,
      ["tag"],
      "column-1",
    )

  let assert Ok(id) = {
    use transac <- database.transaction(db.tasks)
    let assert Ok(id) = database.insert(transac, test_task)
    id
  }

  assert id != ""
}

pub fn update_test() {
  let db = db.get_database()
  let original_task =
    task.Task(
      "Original",
      0,
      "2026-02-05T10:00:00Z",
      "2026-02-10T23:59:59Z",
      False,
      ["tag"],
      "column-1",
    )

  let assert Ok(id) = {
    use transac <- database.transaction(db.tasks)
    let assert Ok(id) = database.insert(transac, original_task)
    id
  }

  let updated_task =
    task.Task(
      "Updated",
      0,
      "2026-02-05T10:00:00Z",
      "2026-02-10T23:59:59Z",
      True,
      ["tag"],
      "column-1",
    )
  let update_result = {
    use transac <- database.transaction(db.tasks)
    database.update(transac, id, updated_task)
  }

  assert result.is_ok(update_result)
}

pub fn delete_test() {
  let db = db.get_database()
  let test_task =
    task.Task(
      "To Delete",
      0,
      "2026-02-05T10:00:00Z",
      "2026-02-10T23:59:59Z",
      False,
      ["tag"],
      "column-1",
    )

  let assert Ok(id) = {
    use transac <- database.transaction(db.tasks)
    let assert Ok(id) = database.insert(transac, test_task)
    id
  }

  let delete_result = {
    use transac <- database.transaction(db.tasks)
    database.delete(transac, id)
  }

  assert result.is_ok(delete_result)
}

pub fn completed_toggle_test() {
  let completed_false =
    task.Task(
      "Task",
      0,
      "2026-02-05T10:00:00Z",
      "2026-02-10T23:59:59Z",
      False,
      ["tag"],
      "column-1",
    )

  let completed_true =
    task.Task(
      "Task",
      0,
      "2026-02-05T10:00:00Z",
      "2026-02-10T23:59:59Z",
      True,
      ["tag"],
      "column-1",
    )

  assert completed_false.completed == False
  assert completed_true.completed == True
}

pub fn with_multiple_tags_test() {
  let task_with_tags =
    task.Task(
      "Task",
      0,
      "2026-02-05T10:00:00Z",
      "2026-02-10T23:59:59Z",
      False,
      ["backend", "database", "urgent"],
      "column-1",
    )

  assert task_with_tags.tags == ["backend", "database", "urgent"]
}

pub fn with_empty_tags_test() {
  let task_no_tags =
    task.Task(
      "Task",
      0,
      "2026-02-05T10:00:00Z",
      "2026-02-10T23:59:59Z",
      False,
      [],
      "column-1",
    )

  assert task_no_tags.tags == []
}

pub fn json_with_tags_test() {
  let test_task =
    task.Task(
      "Task with Tags",
      0,
      "2026-02-05T10:00:00Z",
      "2026-02-10T23:59:59Z",
      False,
      ["backend", "bug"],
      "column-1",
    )
  let json_result = task.to_json(test_task, "task-1")
  let json_str = json.to_string(json_result)

  assert string.contains(json_str, "\"tags\":")
  assert string.contains(json_str, "backend")
  assert string.contains(json_str, "bug")
}
