// Benchmarks for signals library

///|
test "bench: signal get/set" (b : @bench.T) {
  let sig = signal(0)
  b.bench(name="signal_set", fn() { sig.set(1) })
  b.bench(name="signal_get", fn() { b.keep(sig.get()) })
}

///|
test "bench: memo computation" (b : @bench.T) {
  let a = signal(1)
  let b_sig = signal(2)
  let sum = memo(fn() { a.get() + b_sig.get() })

  // Warm up - ensure memo is initialized
  let _ = sum()
  b.bench(name="memo_cached", fn() { b.keep(sum()) })
  b.bench(name="memo_recompute", fn() {
    a.set(a.peek() + 1)
    b.keep(sum())
  })
}

///|
test "bench: render_effect" (b : @bench.T) {
  let sig = signal(0)
  let counter = Ref::new(0)
  let dispose = render_effect(fn() {
    let _ = sig.get()
    counter.val = counter.val + 1
  })
  b.bench(name="effect_trigger", fn() { sig.set(sig.peek() + 1) })
  dispose()
  b.keep(counter.val)
}

///|
test "bench: batch vs non-batch" (b : @bench.T) {
  let a = signal(0)
  let b_sig = signal(0)
  let counter = Ref::new(0)
  let dispose = render_effect(fn() {
    let _ = a.get() + b_sig.get()
    counter.val = counter.val + 1
  })
  b.bench(name="no_batch", fn() {
    a.set(a.peek() + 1)
    b_sig.set(b_sig.peek() + 1)
  })
  b.bench(name="with_batch", fn() {
    batch(fn() {
      a.set(a.peek() + 1)
      b_sig.set(b_sig.peek() + 1)
    })
  })
  dispose()
  b.keep(counter.val)
}

///|
test "bench: deep dependency chain" (b : @bench.T) {
  let source = signal(0)
  let m1 = memo(fn() { source.get() + 1 })
  let m2 = memo(fn() { m1() + 1 })
  let m3 = memo(fn() { m2() + 1 })
  let m4 = memo(fn() { m3() + 1 })

  // Warm up
  let _ = m4()
  b.bench(name="deep_chain_read", fn() { b.keep(m4()) })
  b.bench(name="deep_chain_update", fn() {
    source.set(source.peek() + 1)
    b.keep(m4())
  })
}

///|
test "bench: many subscribers" (b : @bench.T) {
  let sig = signal(0)
  let disposers : Array[() -> Unit] = []
  let counter = Ref::new(0)

  // Create 100 effects subscribing to the same signal
  for i = 0; i < 100; i = i + 1 {
    disposers.push(
      render_effect(fn() {
        let _ = sig.get()
        counter.val = counter.val + 1
      }),
    )
  }
  b.bench(name="notify_100_subscribers", fn() { sig.set(sig.peek() + 1) })

  // Cleanup
  for i = 0; i < disposers.length(); i = i + 1 {
    disposers[i]()
  }
  b.keep(counter.val)
}
