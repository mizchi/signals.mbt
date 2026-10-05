///|
test "AsyncState::Pending" {
  let state : @ui.AsyncState[Int] = Pending
  @debug.debug_inspect(state.is_pending(), content="true")
  @debug.debug_inspect(state.is_success(), content="false")
  @debug.debug_inspect(state.is_failure(), content="false")
  @debug.debug_inspect(state.value(), content="None")
  @debug.debug_inspect(state.error(), content="None")
}

///|
test "AsyncState::Success" {
  let state : @ui.AsyncState[Int] = Success(42)
  @debug.debug_inspect(state.is_pending(), content="false")
  @debug.debug_inspect(state.is_success(), content="true")
  @debug.debug_inspect(state.is_failure(), content="false")
  @debug.debug_inspect(state.value(), content="Some(42)")
  @debug.debug_inspect(state.error(), content="None")
}

///|
test "AsyncState::Failure" {
  let state : @ui.AsyncState[Int] = Failure("error message")
  @debug.debug_inspect(state.is_pending(), content="false")
  @debug.debug_inspect(state.is_success(), content="false")
  @debug.debug_inspect(state.is_failure(), content="true")
  @debug.debug_inspect(state.value(), content="None")
  @debug.debug_inspect(state.error(), content="Some(\"error message\")")
}
