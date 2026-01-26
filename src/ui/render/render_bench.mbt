// Benchmarks for render_to_string
// Run with: moon bench --target js src/ui/render

// =============================================================================
// Test Data - VNode Trees
// =============================================================================

///|
fn vnode_text() -> @ui.Node[Unit, String] {
  @ui.text("Hello, World!")
}

///|
fn vnode_text_escape() -> @ui.Node[Unit, String] {
  @ui.text("<script>alert('xss')</script> & \"dangerous\" content")
}

///|
fn vnode_simple_element() -> @ui.Node[Unit, String] {
  @ui.h("div", [], [@ui.text("content")])
}

///|
fn vnode_with_attrs() -> @ui.Node[Unit, String] {
  @ui.h(
    "div",
    [
      ("id", @ui.attr_static("main")),
      ("class", @ui.attr_static("container mx-auto")),
      ("data-value", @ui.attr_static("{\"count\":42,\"name\":\"test\"}")),
    ],
    [@ui.text("content")],
  )
}

///|
fn vnode_nested() -> @ui.Node[Unit, String] {
  @ui.h("div", [("class", @ui.attr_static("card"))], [
    @ui.h("header", [("class", @ui.attr_static("card-header"))], [
      @ui.h("h2", [], [@ui.text("Title")]),
    ]),
    @ui.h("div", [("class", @ui.attr_static("card-body"))], [
      @ui.h("p", [], [@ui.text("This is the card body content.")]),
      @ui.h("button", [("class", @ui.attr_static("btn"))], [
        @ui.text("Click me"),
      ]),
    ]),
  ])
}

///|
fn vnode_list() -> @ui.Node[Unit, String] {
  let items : Array[@ui.Node[Unit, String]] = []
  for i = 0; i < 10; i = i + 1 {
    items.push(
      @ui.h("li", [("class", @ui.attr_static("item"))], [@ui.text("Item \{i}")]),
    )
  }
  @ui.h("ul", [("class", @ui.attr_static("list"))], items)
}

///|
fn vnode_large_list() -> @ui.Node[Unit, String] {
  let items : Array[@ui.Node[Unit, String]] = []
  for i = 0; i < 100; i = i + 1 {
    items.push(
      @ui.h("li", [("class", @ui.attr_static("item"))], [
        @ui.text("Item \{i} with some <special> & \"characters\""),
      ]),
    )
  }
  @ui.h("ul", [("class", @ui.attr_static("list"))], items)
}

///|
fn vnode_page() -> @ui.Node[Unit, String] {
  @ui.h("html", [], [
    @ui.h("head", [], [
      @ui.h("meta", [("charset", @ui.attr_static("utf-8"))], []),
      @ui.h("title", [], [@ui.text("Test Page")]),
    ]),
    @ui.h("body", [], [
      @ui.h("header", [], [
        @ui.h("nav", [("class", @ui.attr_static("navbar"))], [
          @ui.h("a", [("href", @ui.attr_static("/"))], [@ui.text("Home")]),
          @ui.h("a", [("href", @ui.attr_static("/about"))], [@ui.text("About")]),
        ]),
      ]),
      @ui.h("main", [("class", @ui.attr_static("container"))], [
        @ui.h("h1", [], [@ui.text("Welcome")]),
        @ui.h("p", [], [
          @ui.text("This is a test page with <special> & \"characters\"."),
        ]),
      ]),
      @ui.h("footer", [], [@ui.text("© 2024")]),
    ]),
  ])
}

// =============================================================================
// Render Benchmarks
// =============================================================================

///|
test "render: text" (b : @bench.T) {
  let node = vnode_text()
  b.bench(fn() { b.keep(render_to_string(node)) })
}

///|
test "render: text_escape" (b : @bench.T) {
  let node = vnode_text_escape()
  b.bench(fn() { b.keep(render_to_string(node)) })
}

///|
test "render: simple_element" (b : @bench.T) {
  let node = vnode_simple_element()
  b.bench(fn() { b.keep(render_to_string(node)) })
}

///|
test "render: with_attrs" (b : @bench.T) {
  let node = vnode_with_attrs()
  b.bench(fn() { b.keep(render_to_string(node)) })
}

///|
test "render: nested" (b : @bench.T) {
  let node = vnode_nested()
  b.bench(fn() { b.keep(render_to_string(node)) })
}

///|
test "render: list (10 items)" (b : @bench.T) {
  let node = vnode_list()
  b.bench(fn() { b.keep(render_to_string(node)) })
}

///|
test "render: large_list (100 items with escape)" (b : @bench.T) {
  let node = vnode_large_list()
  b.bench(fn() { b.keep(render_to_string(node)) })
}

///|
test "render: page" (b : @bench.T) {
  let node = vnode_page()
  b.bench(fn() { b.keep(render_to_string(node)) })
}
