///|
test "render simple element" {
  let node : @ui.Node[Unit, String] = @ui.h("div", [], [@ui.text("Hello")])
  inspect(render_to_string(node), content="<div>Hello</div>")
}

///|
test "render element with attributes" {
  let node : @ui.Node[Unit, String] = @ui.h(
    "div",
    [("class", @ui.attr_static("container")), ("id", @ui.attr_static("main"))],
    [@ui.text("Content")],
  )
  inspect(
    render_to_string(node),
    content="<div class=\"container\" id=\"main\">Content</div>",
  )
}

///|
test "render nested elements" {
  let node : @ui.Node[Unit, String] = @ui.h("div", [], [
    @ui.h("span", [], [@ui.text("Nested")]),
  ])
  inspect(render_to_string(node), content="<div><span>Nested</span></div>")
}

///|
test "render void element" {
  let node : @ui.Node[Unit, String] = @ui.h("br", [], [])
  inspect(render_to_string(node), content="<br />")
}

///|
test "render fragment" {
  let node : @ui.Node[Unit, String] = @ui.fragment([
    @ui.text("Hello"),
    @ui.text(" "),
    @ui.text("World"),
  ])
  inspect(render_to_string(node), content="Hello World")
}

///|
test "render show - true" {
  let node : @ui.Node[Unit, String] = @ui.show(fn() { true }, fn() {
    @ui.text("Visible")
  })
  inspect(render_to_string(node), content="Visible")
}

///|
test "render show - false" {
  let node : @ui.Node[Unit, String] = @ui.show(fn() { false }, fn() {
    @ui.text("Hidden")
  })
  inspect(render_to_string(node), content="<!--show-->")
}

///|
test "render for_each" {
  let items = ["a", "b", "c"]
  let node : @ui.Node[Unit, String] = @ui.for_each(fn() {
    items.map(fn(s) { @ui.text(s) })
  })
  inspect(render_to_string(node), content="abc")
}

///|
test "render component" {
  let node : @ui.Node[Unit, String] = @ui.component(fn() {
    @ui.h("div", [], [@ui.text("Component")])
  })
  inspect(render_to_string(node), content="<div>Component</div>")
}

///|
test "render dynamic text" {
  let mut count = 42
  let node : @ui.Node[Unit, String] = @ui.text_dyn(fn() { count.to_string() })
  inspect(render_to_string(node), content="42")
  count = 100
  inspect(render_to_string(node), content="100")
}

///|
test "render dynamic attribute" {
  let mut cls = "active"
  let node : @ui.Node[Unit, String] = @ui.h(
    "div",
    [("class", @ui.attr_dynamic(fn() { cls }))],
    [],
  )
  inspect(render_to_string(node), content="<div class=\"active\"></div>")
  cls = "inactive"
  inspect(render_to_string(node), content="<div class=\"inactive\"></div>")
}

///|
test "render raw html" {
  let node : @ui.Node[Unit, String] = @ui.raw_html("<strong>Bold</strong>")
  inspect(render_to_string(node), content="<strong>Bold</strong>")
}

///|
test "escape html content" {
  let node : @ui.Node[Unit, String] = @ui.text("<script>alert('xss')</script>")
  inspect(
    render_to_string(node),
    content="&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;",
  )
}

///|
test "escape attribute value" {
  let node : @ui.Node[Unit, String] = @ui.h(
    "div",
    [("data-value", @ui.attr_static("a\"b&c"))],
    [],
  )
  inspect(
    render_to_string(node),
    content="<div data-value=\"a&quot;b&amp;c\"></div>",
  )
}

///|
test "render boolean attribute" {
  let node : @ui.Node[Unit, String] = @ui.h(
    "input",
    [("disabled", @ui.attr_static(""))],
    [],
  )
  inspect(render_to_string(node), content="<input disabled />")
}

///|
test "render switch - first match" {
  let state = 1
  let node : @ui.Node[Unit, String] = @ui.switch_(
    cases=[
      @ui.match_case(when=fn() { state == 1 }, render=fn() { @ui.text("One") }),
      @ui.match_case(when=fn() { state == 2 }, render=fn() { @ui.text("Two") }),
    ],
    fallback=Some(fn() { @ui.text("Other") }),
  )
  inspect(render_to_string(node), content="One")
}

///|
test "render switch - fallback" {
  let state = 99
  let node : @ui.Node[Unit, String] = @ui.switch_(
    cases=[
      @ui.match_case(when=fn() { state == 1 }, render=fn() { @ui.text("One") }),
      @ui.match_case(when=fn() { state == 2 }, render=fn() { @ui.text("Two") }),
    ],
    fallback=Some(fn() { @ui.text("Other") }),
  )
  inspect(render_to_string(node), content="Other")
}

///|
test "is_void_element" {
  inspect(is_void_element("br"), content="true")
  inspect(is_void_element("hr"), content="true")
  inspect(is_void_element("img"), content="true")
  inspect(is_void_element("input"), content="true")
  inspect(is_void_element("meta"), content="true")
  inspect(is_void_element("div"), content="false")
  inspect(is_void_element("span"), content="false")
}
