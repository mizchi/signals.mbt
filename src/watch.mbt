// Watch - Advanced signal utilities
// Watch a computed expression and run callback when it changes

///|
/// Watch a computed expression and run callback when it changes.
/// Returns a dispose function.
/// The callback receives (newValue, oldValue).
pub fn[T : Eq] watch(source : () -> T, callback : (T, T) -> Unit) -> () -> Unit {
  let prev_value : Ref[T?] = Ref::new(None)
  render_effect(fn() {
    let new_value = source()
    match prev_value.val {
      Some(old) =>
        if old != new_value {
          callback(new_value, old)
          prev_value.val = Some(new_value)
        }
      None => prev_value.val = Some(new_value)
    }
  })
}

///|
/// Watch with immediate execution (runs callback on first value too).
/// The callback receives (newValue, oldValue?) where oldValue is None on first run.
pub fn[T : Eq] watch_immediate(
  source : () -> T,
  callback : (T, T?) -> Unit,
) -> () -> Unit {
  let prev_value : Ref[T?] = Ref::new(None)
  render_effect(fn() {
    let new_value = source()
    match prev_value.val {
      Some(old) =>
        if old != new_value {
          callback(new_value, Some(old))
          prev_value.val = Some(new_value)
        }
      None => {
        callback(new_value, None)
        prev_value.val = Some(new_value)
      }
    }
  })
}

///|
/// Create a signal that holds the previous value of another signal.
/// Returns a getter function for the previous value (None on first read).
pub fn[T] previous(sig : Signal[T]) -> () -> T? {
  let prev : Ref[T?] = Ref::new(None)
  let current : Ref[T?] = Ref::new(None)
  let _ = render_effect(fn() {
    let new_val = sig.get()
    prev.val = current.val
    current.val = Some(new_val)
  })
  fn() { prev.val }
}

///|
/// Create a signal that holds the previous value with initial value.
/// Unlike `previous`, this returns a plain T instead of T?.
pub fn[T] previous_with_initial(sig : Signal[T], initial : T) -> () -> T {
  let prev : Ref[T] = Ref::new(initial)
  let current : Ref[T?] = Ref::new(None)
  let _ = render_effect(fn() {
    let new_val = sig.get()
    match current.val {
      Some(curr) => prev.val = curr
      None => ()
    }
    current.val = Some(new_val)
  })
  fn() { prev.val }
}
