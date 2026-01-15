# mizchi/signals

Fine-grained reactive signals library for MoonBit. Inspired by [alien-signals](https://github.com/stackblitz/alien-signals) and [Solid.js](https://www.solidjs.com/).

## What are Reactive Signals?

Reactive signals provide a way to manage state that automatically tracks dependencies and propagates changes. When a signal's value changes, all computations and effects that depend on it are automatically updated.

**Key benefits:**
- **Automatic dependency tracking**: No need to manually specify what depends on what
- **Efficient updates**: Only affected computations re-run when values change
- **Composable**: Build complex reactive graphs from simple primitives

**Use cases:**
- **UI frameworks**: Automatically update views when data changes
- **State management**: Manage application state with predictable updates
- **Data pipelines**: Create derived values that stay in sync with source data
- **Game development**: React to game state changes efficiently
- **Real-time systems**: Propagate sensor/input changes through a system

## Installation

```bash
moon add mizchi/signals
```

## API

### Signal

Holds a reactive value and notifies subscribers when it changes.

```moonbit
let count = signal(0)

// Get value (auto-tracked inside effects)
count.get()  // => 0

// Set value
count.set(5)

// Update with function
count.update(fn(n) { n + 1 })

// Get without tracking (doesn't create dependency)
count.peek()
```

### memo / computed

Creates a memoized value that recomputes only when dependencies change.

```moonbit
let a = signal(2)
let b = signal(3)

let sum = memo(fn() { a.get() + b.get() })
sum()  // => 5

a.set(10)
sum()  // => 13 (recomputed)
sum()  // => 13 (cached value)
```

`computed` is an alias for `memo`.

### render_effect

Creates a side effect that re-runs synchronously when signals change.

```moonbit
let count = signal(0)

let dispose = render_effect(fn() {
  println("count = " + count.get().to_string())
})

count.set(1)  // prints "count = 1"
count.set(2)  // prints "count = 2"

dispose()  // stop the effect
```

### effect

Similar to `render_effect`, but the initial execution is deferred via microtask queue (Solid.js `createEffect` style).

```moonbit
let count = signal(0)
let dispose = effect(fn() {
  println("deferred: " + count.get().to_string())
})
// Initial execution happens after current synchronous code completes
```

**Note**: `effect` uses `queue_microtask`, which is environment-specific. See "Environment-specific async behavior" below.

### batch

Batches multiple updates so effects run only once.

```moonbit
let a = signal(0)
let b = signal(0)

let _ = render_effect(fn() {
  println("sum = " + (a.get() + b.get()).to_string())
})

batch(fn() {
  a.set(1)
  b.set(2)
})
// Effect runs only once
```

### on_cleanup

Registers a cleanup function inside an effect. Called before the effect re-runs or when disposed.

```moonbit
let _ = render_effect(fn() {
  let id = set_interval(...)
  on_cleanup(fn() {
    clear_interval(id)
  })
})
```

### create_root

Creates a reactive scope root. Calling dispose stops all effects within.

```moonbit
create_root(fn(dispose) {
  let _ = render_effect(fn() { ... })
  let _ = render_effect(fn() { ... })

  // Stop all effects at once
  dispose()
})
```

### untracked

Runs a function with tracking disabled. Signal reads won't create dependencies.

```moonbit
let _ = render_effect(fn() {
  // This signal read won't create a dependency
  untracked(fn() {
    let _ = some_signal.get()
  })
})
```

## Environment-specific async behavior

This library uses `queue_microtask` for deferred effects (the `effect` function), but microtask scheduling is environment-specific.

- **JS target**: Uses native `queueMicrotask` from browser/Node.js
- **Non-JS targets (wasm/native)**: Falls back to immediate execution

For production use requiring deferred execution, consider implementing environment-appropriate async handling. If synchronous behavior is sufficient, use `render_effect` instead.

## License

MIT
