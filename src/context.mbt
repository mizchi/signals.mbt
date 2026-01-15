// Reactive Context - Tracks current running effect for auto-subscription

///|
/// Global effect ID counter
let effect_id_counter : Ref[Int] = Ref::new(0)

///|
/// Generate a new unique effect ID
pub fn new_effect_id() -> Int {
  let id = effect_id_counter.val
  effect_id_counter.val = id + 1
  id
}

///|
/// Owner - manages lifecycle of reactive computations (Solid.js style)
pub struct Owner {
  id : Int
  parent : Owner?
  children : Array[Owner]
  cleanups : Array[() -> Unit]
  disposers : Array[() -> Unit]
  mut disposed : Bool
}

///|
/// Create a new Owner
pub fn Owner::new(parent : Owner?) -> Owner {
  let owner : Owner = {
    id: new_effect_id(),
    parent,
    children: [],
    cleanups: [],
    disposers: [],
    disposed: false,
  }
  // Register with parent
  if parent is Some(p) {
    p.children.push(owner)
  }
  owner
}

///|
/// Dispose this owner and all its children
pub fn Owner::dispose(self : Owner) -> Unit {
  if self.disposed {
    return
  }
  self.disposed = true
  // Dispose children first (depth-first)
  for i = self.children.length() - 1; i >= 0; i = i - 1 {
    self.children[i].dispose()
  }
  // Run disposers (for effects)
  for i = self.disposers.length() - 1; i >= 0; i = i - 1 {
    self.disposers[i]()
  }
  // Run cleanups
  for i = self.cleanups.length() - 1; i >= 0; i = i - 1 {
    self.cleanups[i]()
  }
  // Clear arrays
  self.children.clear()
  self.disposers.clear()
  self.cleanups.clear()
  // Remove from parent's children
  if self.parent is Some(p) {
    p.children.retain(fn(child) { child.id != self.id })
  }
}

///|
/// Reactive context - tracks currently running computation
priv struct ReactiveContext {
  mut current_owner : Owner?
  mut current_cleanups : Array[() -> Unit]?
  mut batch_depth : Int
}

///|
/// Global reactive context instance
let reactive_context : ReactiveContext = {
  current_owner: None,
  current_cleanups: None,
  batch_depth: 0,
}

///|
/// Run a function without tracking (useful for avoiding circular deps).
/// Signal reads inside this function won't create subscriptions.
pub fn[T] untracked(f : () -> T) -> T {
  // Disable core tracking
  let prev_core = set_active_sub(None)
  let result = f()
  let _ = set_active_sub(prev_core)
  result
}

///|
/// Start a batch update - effects won't run until batch ends
pub fn batch_start() -> Unit {
  reactive_context.batch_depth = reactive_context.batch_depth + 1
  start_batch()
}

///|
/// End a batch update - run all pending effects
pub fn batch_end() -> Unit {
  reactive_context.batch_depth = reactive_context.batch_depth - 1
  end_batch()
}

///|
/// Run a function in a batch - all signal updates are batched.
/// Effects only run once after all updates complete.
pub fn[T] batch(f : () -> T) -> T {
  batch_start()
  let result = f()
  batch_end()
  result
}

///|
/// Check if we're currently inside a batch
pub fn is_batching() -> Bool {
  reactive_context.batch_depth > 0
}

///|
/// Register a cleanup function to run when the current scope disposes.
/// Works in:
/// - Effects: cleanup runs before effect re-runs or when effect disposes
/// - Components: cleanup runs when component unmounts
/// (Solid.js style - can be called directly in component body)
pub fn on_cleanup(cleanup : () -> Unit) -> Unit {
  // First priority: effect-level cleanup tracking
  if reactive_context.current_cleanups is Some(cleanups) {
    cleanups.push(cleanup)
  } else if reactive_context.current_owner is Some(owner) {
    // Second priority: owner-level cleanup (for component body)
    owner.cleanups.push(cleanup)
  }
  // No tracking scope, ignore
}

///|
/// Set the current cleanup array (used internally by effect)
pub fn set_current_cleanups(
  cleanups : Array[() -> Unit]?,
) -> Array[() -> Unit]? {
  let prev = reactive_context.current_cleanups
  reactive_context.current_cleanups = cleanups
  prev
}

///|
/// Run a function with cleanup tracking enabled
pub fn[T] run_with_cleanup_tracking(
  cleanups : Array[() -> Unit],
  f : () -> T,
) -> T {
  let prev = set_current_cleanups(Some(cleanups))
  let result = f()
  reactive_context.current_cleanups = prev
  result
}

// ============================================================================
// Owner-based scope management (Solid.js style)
// ============================================================================

///|
/// Get the current owner (if any)
pub fn get_owner() -> Owner? {
  reactive_context.current_owner
}

///|
/// Run a function with a specific owner as current
pub fn[T] run_with_owner(owner : Owner, f : () -> T) -> T {
  let prev = reactive_context.current_owner
  reactive_context.current_owner = Some(owner)
  let result = f()
  reactive_context.current_owner = prev
  result
}

///|
/// Create a new reactive root scope.
/// The function receives a dispose callback that cleans up all effects.
/// Returns the result of the function.
pub fn[T] create_root(f : (() -> Unit) -> T) -> T {
  let owner = Owner::new(reactive_context.current_owner)
  let dispose = fn() { owner.dispose() }
  run_with_owner(owner, fn() { f(dispose) })
}

///|
/// Create a reactive root and return both result and dispose function
pub fn[T] create_root_with_dispose(f : () -> T) -> (T, () -> Unit) {
  let owner = Owner::new(reactive_context.current_owner)
  let dispose = fn() { owner.dispose() }
  let result = run_with_owner(owner, f)
  (result, dispose)
}

///|
/// Register a disposer with the current owner
/// Called internally by effect() to register its dispose function
pub fn register_disposer(disposer : () -> Unit) -> Unit {
  if reactive_context.current_owner is Some(owner) {
    owner.disposers.push(disposer)
  }
}

///|
/// Register a cleanup with the current owner (alternative to onCleanup in effect)
pub fn register_owner_cleanup(cleanup : () -> Unit) -> Unit {
  if reactive_context.current_owner is Some(owner) {
    owner.cleanups.push(cleanup)
  }
}

///|
/// Check if currently inside an owner scope
pub fn has_owner() -> Bool {
  reactive_context.current_owner is Some(_)
}

///|
/// Run a function with a captured parent owner context (if any)
/// This is useful for rendering child components that need to inherit the parent's owner.
/// If captured_owner is Some, runs with that owner as context.
/// If captured_owner is None, runs directly without owner context.
pub fn[T] with_parent_owner(captured_owner : Owner?, f : () -> T) -> T {
  match captured_owner {
    Some(parent) => run_with_owner(parent, f)
    None => f()
  }
}
