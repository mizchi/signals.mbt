///|
test "h creates Element node" {
  let node : @ui.Node[Unit, String] = @ui.h(
    "div",
    [("class", @ui.attr_static("container"))],
    [@ui.text("Hello")],
  )
  guard node is Element(el) else { fail("expected Element") }
  inspect(el.tag, content="div")
}

///|
test "text creates Text node" {
  let node : @ui.Node[Unit, String] = @ui.text("Hello World")
  guard node is Text(s) else { fail("expected Text") }
  inspect(s, content="Hello World")
}

///|
test "text_dyn creates DynamicText node" {
  let mut count = 5
  let node : @ui.Node[Unit, String] = @ui.text_dyn(fn() { count.to_string() })
  guard node is DynamicText(getter) else { fail("expected DynamicText") }
  inspect(getter(), content="5")
  count = 10
  inspect(getter(), content="10")
}

///|
test "fragment creates Fragment node" {
  let node : @ui.Node[Unit, String] = @ui.fragment([
    @ui.text("Hello"),
    @ui.text(" "),
    @ui.text("World"),
  ])
  guard node is Fragment(children) else { fail("expected Fragment") }
  inspect(children.length(), content="3")
}

///|
test "show creates conditional node" {
  let visible = true
  let node : @ui.Node[Unit, String] = @ui.show(fn() { visible }, fn() {
    @ui.text("Visible!")
  })
  guard node is Show(condition~, ..) else { fail("expected Show") }
  inspect(condition(), content="true")
}

///|
test "for_each creates list node" {
  let items = ["a", "b", "c"]
  let node : @ui.Node[Unit, String] = @ui.for_each(fn() {
    items.map(fn(s) { @ui.text(s) })
  })
  guard node is For(render~) else { fail("expected For") }
  inspect(render().length(), content="3")
}

///|
test "component creates Component node" {
  let node : @ui.Node[Unit, String] = @ui.component(fn() {
    @ui.h("div", [], [@ui.text("Component")])
  })
  guard node is Component(render~) else { fail("expected Component") }
  guard render() is Element(el) else { fail("expected Element") }
  inspect(el.tag, content="div")
}

///|
test "attr_static creates static attribute" {
  let attr : @ui.Attr[Unit, String] = @ui.attr_static("my-class")
  guard attr is VStatic(v) else { fail("expected VStatic") }
  inspect(v, content="my-class")
}

///|
test "attr_dynamic creates dynamic attribute" {
  let mut count = 0
  let attr : @ui.Attr[Unit, String] = @ui.attr_dynamic(fn() {
    "count-" + count.to_string()
  })
  guard attr is VDynamic(getter) else { fail("expected VDynamic") }
  inspect(getter(), content="count-0")
  count = 5
  inspect(getter(), content="count-5")
}

///|
test "handler creates EventHandler" {
  let h : @ui.EventHandler[Int] = @ui.handler(fn(x) { let _ = x * 2 })
  inspect(h.get_callback()(5), content="()")
}

///|
test "raw_html creates RawHtml node" {
  let node : @ui.Node[Unit, String] = @ui.raw_html("<strong>Bold</strong>")
  guard node is RawHtml(html) else { fail("expected RawHtml") }
  inspect(html, content="<strong>Bold</strong>")
}

///|
test "has_dynamic_content detects dynamic attrs" {
  let static_attrs : Array[(String, @ui.Attr[Unit, String])] = [
    ("class", @ui.attr_static("foo")),
  ]
  inspect(@ui.has_dynamic_content(static_attrs), content="false")
  let dynamic_attrs : Array[(String, @ui.Attr[Unit, String])] = [
    ("class", @ui.attr_dynamic(fn() { "foo" })),
  ]
  inspect(@ui.has_dynamic_content(dynamic_attrs), content="true")
  let handler_attrs : Array[(String, @ui.Attr[Unit, String])] = [
    ("onclick", @ui.attr_handler(@ui.handler(fn(_x : Unit) {  }))),
  ]
  inspect(@ui.has_dynamic_content(handler_attrs), content="true")
}
