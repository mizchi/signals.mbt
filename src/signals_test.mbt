// Basic tests for signals

///|
test "signal basic" {
  let count = signal(0)
  inspect(count.get(), content="0")
  count.set(5)
  inspect(count.get(), content="5")
}

///|
test "signal update" {
  let count = signal(10)
  count.update(fn(n) { n * 2 })
  inspect(count.get(), content="20")
  count.update(fn(n) { n + 5 })
  inspect(count.get(), content="25")
}

///|
test "signal peek" {
  let count = signal(0)
  let runs : Ref[Int] = Ref::new(0)
  let _ = render_effect(fn() {
    // peek() won't create dependency
    let _ = count.peek()
    runs.val = runs.val + 1
  })
  count.set(1)
  count.set(2)
  // Effect only ran once (initial), not on updates
  inspect(runs.val, content="1")
}

///|
test "render_effect basic" {
  let count = signal(0)
  let log : Array[Int] = []
  let _ = render_effect(fn() { log.push(count.get()) })
  count.set(1)
  count.set(2)
  inspect(log, content="[0, 1, 2]")
}

///|
test "render_effect dispose" {
  let count = signal(0)
  let log : Array[String] = []
  let dispose = render_effect(fn() {
    log.push("count=" + count.get().to_string())
  })
  log.push("after-effect")
  count.set(1)
  dispose()
  count.set(2) // Won't trigger effect
  let expected =
    #|["count=0", "after-effect", "count=1"]
  inspect(log, content=expected)
}

///|
test "memo basic" {
  let a = signal(2)
  let b = signal(3)
  let compute_count : Ref[Int] = Ref::new(0)
  let sum = memo(fn() {
    compute_count.val = compute_count.val + 1
    a.get() + b.get()
  })
  inspect(sum(), content="5")
  inspect(sum(), content="5") // Cached, no recompute
  inspect(compute_count.val, content="1")
  a.set(10)
  inspect(sum(), content="13") // Recomputes
  inspect(compute_count.val, content="2")
}

///|
test "computed alias" {
  let count = signal(5)
  let doubled = computed(fn() { count.get() * 2 })
  inspect(doubled(), content="10")
  count.set(7)
  inspect(doubled(), content="14")
}

///|
test "batch updates" {
  let a = signal(0)
  let b = signal(0)
  let runs : Ref[Int] = Ref::new(0)
  let _ = render_effect(fn() {
    let _ = a.get() + b.get()
    runs.val = runs.val + 1
  })
  inspect(runs.val, content="1") // Initial run
  batch(fn() {
    a.set(1)
    b.set(2)
  })
  // Only one additional run, not two
  inspect(runs.val, content="2")
}

///|
test "on_cleanup in effect" {
  let count = signal(0)
  let log : Array[String] = []
  let dispose = render_effect(fn() {
    let v = count.get()
    log.push("run:" + v.to_string())
    on_cleanup(fn() { log.push("cleanup:" + v.to_string()) })
  })
  count.set(1)
  dispose()
  let expected =
    #|["run:0", "cleanup:0", "run:1", "cleanup:1"]
  inspect(log, content=expected)
}

///|
test "create_root dispose" {
  let count = signal(0)
  let log : Array[Int] = []
  let result = create_root(fn(dispose) {
    let _ = render_effect(fn() { log.push(count.get()) })
    dispose // Return dispose function
  })
  count.set(1)
  result() // Dispose the root
  count.set(2) // Won't trigger effect
  inspect(log, content="[0, 1]")
}

///|
test "untracked reads" {
  let count = signal(0)
  let runs : Ref[Int] = Ref::new(0)
  let _ = render_effect(fn() {
    untracked(fn() {
      let _ = count.get() // Won't create dependency
      runs.val = runs.val + 1
    })
  })
  count.set(1)
  count.set(2)
  // Effect only ran once (initial), not on updates
  inspect(runs.val, content="1")
}

///|
test "effect_when conditional" {
  let enabled = signal(false)
  let count = signal(0)
  let log : Array[Int] = []
  let _ = effect_when(fn() { enabled.get() }, fn() { log.push(count.get()) })
  count.set(1) // Won't run, enabled is false
  enabled.set(true)
  count.set(2)
  inspect(log, content="[1, 2]")
}
