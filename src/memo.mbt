// Memo - Cached computed value that updates when dependencies change

///|
/// Create a memoized computation.
/// Returns a getter function that caches the result and recomputes only when dependencies change.
pub fn[T] memo(compute : () -> T) -> () -> T {
  let inner = create_computed(compute)
  fn() { inner.get() }
}

///|
/// Create a computed signal (alias for memo with Signal-like API).
/// Same as `memo`, but named to be more familiar for those coming from other reactive frameworks.
pub fn[T] computed(compute : () -> T) -> () -> T {
  memo(compute)
}
