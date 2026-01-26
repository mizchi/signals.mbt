// VNode - DOM-independent virtual node representation
//
// Type parameter E represents the event type for handlers:
// - Browser: E = DomEvent (or specific event types)
// - SSR: E = Unit (no events)
// - Other platforms: custom event types
//

///|
/// Event handler type - newtype wrapper for callback function
pub struct EventHandler[E] {
  callback : (E) -> Unit
}

///|
/// Create an event handler from a callback.
pub fn[E] handler(f : (E) -> Unit) -> EventHandler[E] {
  { callback: f }
}

///|
/// Get the callback function
pub fn[E] EventHandler::get_callback(self : EventHandler[E]) -> (E) -> Unit {
  self.callback
}

///|
/// Attribute value that can be static or dynamic (signal-based)
/// Type parameter A represents the attribute value type:
/// - Web: A = String (HTML attributes are strings)
/// - TUI: A = TuiAttrValue (typed values like Dimension, Color)
pub(all) enum Attr[E, A] {
  VStatic(A)
  VDynamic(() -> A)
  VHandler(EventHandler[E])
}

///|
/// Virtual DOM node types
/// Type parameter A represents the attribute value type (see Attr[E, A])
pub(all) enum Node[E, A] {
  Element(VElement[E, A])
  Text(String)
  DynamicText(() -> String)
  Fragment(Array[Node[E, A]])
  Show(condition~ : () -> Bool, child~ : () -> Node[E, A])
  For(render~ : () -> Array[Node[E, A]])
  Component(render~ : () -> Node[E, A])
  /// Async node - renders content asynchronously with fallback
  Async(VAsync[E, A])
  /// ErrorBoundary node - catches rendering errors in children
  ErrorBoundary(VErrorBoundary[E, A])
  /// Switch node - renders first matching case or fallback
  Switch(VSwitch[E, A])
  /// Raw HTML string - rendered without escaping
  RawHtml(String)
}

///|
/// Virtual element node
pub struct VElement[E, A] {
  tag : String
  attrs : Array[(String, Attr[E, A])]
  children : Array[Node[E, A]]
}

///|
/// Virtual Async node for async rendering with error handling
pub struct VAsync[E, A] {
  render : async () -> Node[E, A]
  fallback : () -> Node[E, A]
  on_error : ((Error) -> Node[E, A])?
}

///|
/// Virtual ErrorBoundary node for catching rendering errors
pub struct VErrorBoundary[E, A] {
  children : () -> Node[E, A] raise
  fallback : (Error, () -> Unit) -> Node[E, A] raise
}

///|
/// Match case for Switch - pairs a condition with content
pub struct MatchCase[E, A] {
  when : () -> Bool
  render : () -> Node[E, A]
}

///|
/// Virtual Switch node - renders first matching case
pub struct VSwitch[E, A] {
  cases : Array[MatchCase[E, A]]
  fallback : (() -> Node[E, A])?
}

// =============================================================================
// Node constructors
// =============================================================================

///|
/// Create a VNode element.
pub fn[E, A] h(
  tag : String,
  attrs : Array[(String, Attr[E, A])],
  children : Array[Node[E, A]],
) -> Node[E, A] {
  Element({ tag, attrs, children })
}

///|
/// Create a text VNode.
pub fn[E, A] text(content : String) -> Node[E, A] {
  Text(content)
}

///|
/// Create a dynamic text VNode.
pub fn[E, A] text_dyn(content : () -> String) -> Node[E, A] {
  DynamicText(content)
}

///|
/// Create a fragment VNode.
pub fn[E, A] fragment(children : Array[Node[E, A]]) -> Node[E, A] {
  Fragment(children)
}

///|
/// Create a raw HTML VNode (content is not escaped).
pub fn[E, A] raw_html(content : String) -> Node[E, A] {
  RawHtml(content)
}

///|
/// Create a conditional VNode.
pub fn[E, A] show(when : () -> Bool, child : () -> Node[E, A]) -> Node[E, A] {
  Show(condition=when, child~)
}

///|
/// Create a list VNode.
pub fn[E, A] for_each(items : () -> Array[Node[E, A]]) -> Node[E, A] {
  For(render=items)
}

///|
/// Create a component VNode.
pub fn[E, A] component(render : () -> Node[E, A]) -> Node[E, A] {
  Component(render~)
}

///|
/// Create an async VNode with fallback
pub fn[E, A] async_(
  render~ : async () -> Node[E, A],
  fallback~ : () -> Node[E, A],
  on_error? : ((Error) -> Node[E, A])? = None,
) -> Node[E, A] {
  Async({ render, fallback, on_error })
}

///|
/// Create an error boundary VNode
pub fn[E, A] error_boundary(
  children~ : () -> Node[E, A] raise,
  fallback~ : (Error, () -> Unit) -> Node[E, A] raise,
) -> Node[E, A] {
  ErrorBoundary({ children, fallback })
}

///|
/// Create a match case for Switch
pub fn[E, A] match_case(
  when~ : () -> Bool,
  render~ : () -> Node[E, A],
) -> MatchCase[E, A] {
  { when, render }
}

///|
/// Create a switch VNode - renders first matching case
pub fn[E, A] switch_(
  cases~ : Array[MatchCase[E, A]],
  fallback? : (() -> Node[E, A])? = None,
) -> Node[E, A] {
  Switch({ cases, fallback })
}

// =============================================================================
// Attr constructors
// =============================================================================

///|
/// Create a static attribute value.
pub fn[E, A] attr_static(value : A) -> Attr[E, A] {
  VStatic(value)
}

///|
/// Create a dynamic attribute value.
pub fn[E, A] attr_dynamic(getter : () -> A) -> Attr[E, A] {
  VDynamic(getter)
}

///|
/// Create a handler attribute value
pub fn[E, A] attr_handler(handler : EventHandler[E]) -> Attr[E, A] {
  VHandler(handler)
}

///|
/// Create a style attribute value (string form)
pub fn[E] attr_style(style : String) -> Attr[E, String] {
  VStatic(style)
}

///|
/// Create a dynamic style attribute value
pub fn[E] attr_dynamic_style(getter : () -> String) -> Attr[E, String] {
  VDynamic(getter)
}

///|
/// Check if element has dynamic content that needs hydration
pub fn[E, A] has_dynamic_content(attrs : Array[(String, Attr[E, A])]) -> Bool {
  for attr in attrs {
    let (_, value) = attr
    match value {
      VDynamic(_) | VHandler(_) => return true
      _ => ()
    }
  }
  false
}
