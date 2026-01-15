// Effect - Reactive side effect that auto-tracks signal dependencies

///|
/// Create an effect that runs immediately and re-runs when dependencies change.
/// (Solid.js style createRenderEffect - synchronous execution)
/// Returns a dispose function to stop the effect.
/// Supports `on_cleanup()` calls inside the effect.
pub fn render_effect(fn_ : () -> Unit) -> () -> Unit {
  let cleanups : Array[() -> Unit] = []

  // Wrap function to enable signal's on_cleanup tracking
  let wrapped_fn = fn() {
    // Run cleanups from previous run
    for i = cleanups.length() - 1; i >= 0; i = i - 1 {
      cleanups[i]()
    }
    cleanups.clear()
    // Run with cleanup tracking enabled
    run_with_cleanup_tracking(cleanups, fn_)
  }
  let dispose = core_render_effect(wrapped_fn)

  // Create dispose function that also runs cleanups
  let full_dispose = fn() {
    // Run final cleanups
    for i = cleanups.length() - 1; i >= 0; i = i - 1 {
      cleanups[i]()
    }
    cleanups.clear()
    dispose()
  }

  // Register with current owner if present
  register_disposer(full_dispose)
  full_dispose
}

///|
/// Create an effect that is deferred until after rendering completes.
/// (Solid.js style createEffect - deferred execution via microtask)
/// Returns a dispose function to stop the effect.
/// Unlike `render_effect`, this runs asynchronously via microtask queue.
pub fn effect(fn_ : () -> Unit) -> () -> Unit {
  let active = Ref::new(true)
  let dispose_ref : Ref[(() -> Unit)?] = Ref::new(None)
  let cleanups : Array[() -> Unit] = []

  // Wrap function to enable signal's on_cleanup tracking
  let wrapped_fn = fn() {
    // Run cleanups from previous run
    for i = cleanups.length() - 1; i >= 0; i = i - 1 {
      cleanups[i]()
    }
    cleanups.clear()
    // Run with cleanup tracking enabled
    run_with_cleanup_tracking(cleanups, fn_)
  }

  // Defer initial run via microtask (like Solid.js createEffect)
  queue_microtask(fn() {
    if active.val {
      dispose_ref.val = Some(core_render_effect(wrapped_fn))
    }
  })

  // Create dispose function
  let dispose = fn() {
    active.val = false
    // Run final cleanups
    for i = cleanups.length() - 1; i >= 0; i = i - 1 {
      cleanups[i]()
    }
    cleanups.clear()
    if dispose_ref.val is Some(d) {
      d()
    }
  }

  // Register with current owner if present
  register_disposer(dispose)
  dispose
}

///|
/// Create an effect that only runs when condition is true.
/// Uses `render_effect` for synchronous execution.
pub fn effect_when(condition : () -> Bool, fn_ : () -> Unit) -> () -> Unit {
  render_effect(fn() { if condition() { fn_() } })
}

///|
/// Create a one-time effect that disposes itself after first run.
/// Useful for initialization logic that should only run once.
pub fn effect_once(fn_ : () -> Unit) -> Unit {
  let dispose : Ref[(() -> Unit)?] = Ref::new(None)
  dispose.val = Some(
    render_effect(fn() {
      fn_()
      // Dispose after first run
      if dispose.val is Some(d) {
        d()
      }
    }),
  )
}

///|
/// Run a function once after mount (Solid.js style onMount).
/// The function runs without tracking dependencies.
/// Cleanup registered via `on_cleanup` inside will run when owner is disposed.
pub fn on_mount(fn_ : () -> Unit) -> Unit {
  // Run untracked so we don't create any subscriptions
  untracked(fn_)
}
