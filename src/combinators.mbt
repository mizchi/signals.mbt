// Signal Combinators - Transform and combine signals

///|
/// Map a signal's value through a function.
/// Returns a getter function (like memo) that recomputes when the signal changes.
pub fn[T, U] sig_map(sig : Signal[T], f : (T) -> U) -> () -> U {
  memo(fn() { f(sig.get()) })
}

///|
/// Filter signal updates - only updates when predicate is true.
/// Returns a signal that only updates when predicate passes.
pub fn[T] sig_filter(sig : Signal[T], predicate : (T) -> Bool) -> Signal[T?] {
  let result : Signal[T?] = signal(None)
  let _ = render_effect(fn() {
    let value = sig.get()
    if predicate(value) {
      result.set(Some(value))
    }
  })
  result
}

///|
/// Filter and map signal updates
/// Uses render_effect for synchronous execution
pub fn[T, U] sig_filter_map(sig : Signal[T], f : (T) -> U?) -> Signal[U?] {
  let result : Signal[U?] = signal(None)
  let _ = render_effect(fn() {
    let value = sig.get()
    match f(value) {
      Some(mapped) => result.set(Some(mapped))
      None => ()
    }
  })
  result
}

///|
/// Combine two signals into one.
/// The getter recomputes when either signal changes.
pub fn[A, B, R] combine2(
  a : Signal[A],
  b : Signal[B],
  f : (A, B) -> R,
) -> () -> R {
  memo(fn() { f(a.get(), b.get()) })
}

///|
/// Combine three signals into one
pub fn[A, B, C, R] combine3(
  a : Signal[A],
  b : Signal[B],
  c : Signal[C],
  f : (A, B, C) -> R,
) -> () -> R {
  memo(fn() { f(a.get(), b.get(), c.get()) })
}

///|
/// Combine four signals into one
pub fn[A, B, C, D, R] combine4(
  a : Signal[A],
  b : Signal[B],
  c : Signal[C],
  d : Signal[D],
  f : (A, B, C, D) -> R,
) -> () -> R {
  memo(fn() { f(a.get(), b.get(), c.get(), d.get()) })
}

///|
/// Create a signal that is true when all input signals are true.
pub fn all(signals : Array[Signal[Bool]]) -> () -> Bool {
  memo(fn() {
    for sig in signals {
      if not(sig.get()) {
        break false
      }
    } else {
      true
    }
  })
}

///|
/// Create a signal that is true when any input signal is true.
pub fn any(signals : Array[Signal[Bool]]) -> () -> Bool {
  memo(fn() {
    for sig in signals {
      if sig.get() {
        break true
      }
    } else {
      false
    }
  })
}

///|
/// Select from an array signal by index signal.
/// Returns None if index is out of bounds.
pub fn[T] select(items : Signal[Array[T]], index : Signal[Int]) -> () -> T? {
  memo(fn() {
    let arr = items.get()
    let idx = index.get()
    if idx >= 0 && idx < arr.length() {
      Some(arr[idx])
    } else {
      None
    }
  })
}

///|
/// Create a read-only getter for a signal
pub fn[T] to_getter(sig : Signal[T]) -> () -> T {
  fn() { sig.get() }
}

///|
/// Flatten a signal of signals.
/// Unwraps nested Signal[Signal[T]] to a getter for T.
pub fn[T] flatten(outer : Signal[Signal[T]]) -> () -> T {
  memo(fn() { outer.get().get() })
}

///|
/// Switch between signals based on a boolean signal.
/// Returns value from on_true when condition is true, otherwise on_false.
pub fn[T] switch_(
  condition : Signal[Bool],
  on_true : Signal[T],
  on_false : Signal[T],
) -> () -> T {
  memo(fn() { if condition.get() { on_true.get() } else { on_false.get() } })
}
