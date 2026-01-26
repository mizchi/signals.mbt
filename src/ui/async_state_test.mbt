///|
test "AsyncState::Pending" {
  let state : AsyncState[Int] = Pending
  inspect(state.is_pending(), content="true")
  inspect(state.is_success(), content="false")
  inspect(state.is_failure(), content="false")
  inspect(state.value(), content="None")
  inspect(state.error(), content="None")
}

///|
test "AsyncState::Success" {
  let state : AsyncState[Int] = Success(42)
  inspect(state.is_pending(), content="false")
  inspect(state.is_success(), content="true")
  inspect(state.is_failure(), content="false")
  inspect(state.value(), content="Some(42)")
  inspect(state.error(), content="None")
}

///|
test "AsyncState::Failure" {
  let state : AsyncState[Int] = Failure("error message")
  inspect(state.is_pending(), content="false")
  inspect(state.is_success(), content="false")
  inspect(state.is_failure(), content="true")
  inspect(state.value(), content="None")
  inspect(state.error(), content="Some(\"error message\")")
}
