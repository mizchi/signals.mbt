// Signal - Reactive value container with automatic dependency tracking

///|
/// Signal type - holds a value and notifies subscribers on change.
/// A reactive primitive that stores a value and automatically tracks dependencies.
pub struct Signal[T] {
  inner : CoreSignal[T]
}

///|
/// Create a new signal with initial value.
pub fn[T] Signal::new(initial : T) -> Signal[T] {
  { inner: core_signal(initial) }
}

///|
/// Get the current value and track dependency if inside an effect.
/// When called inside an `effect` or `memo`, automatically subscribes to changes.
pub fn[T] Signal::get(self : Signal[T]) -> T {
  self.inner.get()
}

///|
/// Set a new value and notify all subscribers.
pub fn[T] Signal::set(self : Signal[T], new_value : T) -> Unit {
  self.inner.set(new_value)
}

///|
/// Update the value using a function.
/// Useful for updating based on current value.
pub fn[T] Signal::update(self : Signal[T], f : (T) -> T) -> Unit {
  self.inner.update(f)
}

///|
/// Get value without tracking (won't create dependency).
/// Useful when you need to read a signal without subscribing to it.
pub fn[T] Signal::peek(self : Signal[T]) -> T {
  self.inner.peek()
}

///|
/// Clear all subscribers (for cleanup)
pub fn[T] Signal::clear_subscribers(self : Signal[T]) -> Unit {
  self.inner.clear_subscribers()
}

///|
/// Get number of subscribers (for debugging)
pub fn[T] Signal::subscriber_count(self : Signal[T]) -> Int {
  self.inner.subscriber_count()
}

///|
/// Convenience function to create a signal.
/// Shorthand for `Signal::new`.
pub fn[T] signal(initial : T) -> Signal[T] {
  Signal::new(initial)
}

///|
/// Explicitly subscribe to a signal with a callback.
/// Returns an unsubscribe function.
/// Unlike `effect()`, this doesn't auto-track and only listens to this one signal.
/// Callback is NOT called on initial subscription, only on subsequent changes.
pub fn[T] on(sig : Signal[T], callback : (T) -> Unit) -> () -> Unit {
  let first_run = Ref::new(true)
  render_effect(fn() {
    let value = sig.get()
    if first_run.val {
      first_run.val = false
    } else {
      callback(value)
    }
  })
}

///|
/// Subscribe and run immediately with current value.
/// Like `on`, but also invokes the callback with the current value right away.
pub fn[T] on_immediate(sig : Signal[T], callback : (T) -> Unit) -> () -> Unit {
  render_effect(fn() {
    let value = sig.get()
    callback(value)
  })
}
