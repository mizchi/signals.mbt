// VNode → HTML String Renderer
//
// Pure MoonBit implementation - works on all targets (js, wasm-gc, native)
// This is the basic renderer without Island/Hydration support.

///|
/// Render a VNode to HTML string
pub fn[E, A : Show] render_to_string(node : @ui.Node[E, A]) -> String {
  let sb = StringBuilder::new(size_hint=256)
  render_to_sb(sb, node)
  sb.to_string()
}

///|
/// Render a VNode to StringBuilder
pub fn[E, A : Show] render_to_sb(
  sb : StringBuilder,
  node : @ui.Node[E, A],
) -> Unit {
  match node {
    Text(content) => escape_html_to(sb, content)
    DynamicText(getter) => escape_html_to(sb, getter())
    RawHtml(html) => sb.write_string(html)
    Fragment(children) =>
      for child in children {
        render_to_sb(sb, child)
      }
    Element(elem) => {
      let tag = elem.tag
      sb.write_char('<')
      sb.write_string(tag)
      render_attrs_to(sb, elem.attrs)
      if is_void_element(tag) {
        sb.write_string(" />")
      } else {
        sb.write_char('>')
        for child in elem.children {
          render_to_sb(sb, child)
        }
        sb.write_string("</")
        sb.write_string(tag)
        sb.write_char('>')
      }
    }
    Show(condition~, child~) =>
      if condition() {
        render_to_sb(sb, child())
      } else {
        sb.write_string("<!--show-->")
      }
    For(render~) =>
      for item in render() {
        render_to_sb(sb, item)
      }
    Component(render~) => render_to_sb(sb, render())
    Async(async_node) =>
      // In sync rendering, render fallback
      render_to_sb(sb, (async_node.fallback)())
    ErrorBoundary(boundary) =>
      // Try rendering children, catch errors and render fallback
      render_to_sb(sb, (boundary.children)()) catch {
        err => {
          let reset = fn() { () }
          render_to_sb(sb, (boundary.fallback)(err, reset)) catch {
            _ => ()
          }
        }
      }
    Switch(switch_node) => {
      // Find first matching case and render it
      for case_ in switch_node.cases {
        if (case_.when)() {
          render_to_sb(sb, (case_.render)())
          return
        }
      }
      // No case matched, render fallback if present
      match switch_node.fallback {
        Some(fallback_fn) => render_to_sb(sb, fallback_fn())
        None => sb.write_string("<!--switch-->")
      }
    }
  }
}

///|
/// Render attributes to StringBuilder
pub fn[E, A : Show] render_attrs_to(
  sb : StringBuilder,
  attrs : Array[(String, @ui.Attr[E, A])],
) -> Unit {
  for attr in attrs {
    let (name, value) = attr
    match value {
      VStatic(s) => render_attr_value(sb, name, s.to_string())
      VDynamic(getter) => render_attr_value(sb, name, getter().to_string())
      VHandler(_) => () // Event handlers are not rendered in SSR
    }
  }
}

///|
/// Render a single attribute value
pub fn render_attr_value(sb : StringBuilder, name : String, s : String) -> Unit {
  match s {
    "__remove__" => () // Special marker to skip attribute
    "" => {
      // Boolean attribute (like disabled)
      sb.write_char(' ')
      sb.write_string(name)
    }
    _ => {
      sb.write_char(' ')
      sb.write_string(name)
      sb.write_string("=\"")
      escape_attr_to(sb, s)
      sb.write_char('"')
    }
  }
}
