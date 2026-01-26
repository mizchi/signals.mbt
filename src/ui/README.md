# @mizchi/signals/ui

Platform-independent Virtual Node (VNode) representation.

## Overview

This module provides:

- **VNode**: Platform-agnostic virtual DOM node types
- **AsyncState**: Generic async state representation

## Design

Type parameters `E` (event type) and `A` (attribute value type) enable the same VNode definitions across different platforms:

| Platform | E | A |
|----------|---|---|
| Browser | `DomEvent` | `String` |
| SSR | `Unit` | `String` |
| TUI | `TuiEvent` | `TuiAttrValue` |

## Usage

### Basic Elements

```moonbit
// Text node
let text_node : Node[Unit, String] = text("Hello World")

// Element node
let div : Node[Unit, String] = h(
  "div",
  [("class", attr_static("container"))],
  [text("Content")]
)

// Nested elements
let nested : Node[Unit, String] = h("div", [], [
  h("span", [], [text("Title")]),
  h("p", [], [text("Paragraph")])
])
```

### Dynamic Content

```moonbit
// Dynamic text (value from getter function)
let count = @signals.signal(0)
let dynamic : Node[Unit, String] = text_dyn(fn() { count.get().to_string() })

// Dynamic attribute
let cls = @signals.signal("active")
let dynamic_attr : Node[Unit, String] = h(
  "div",
  [("class", attr_dynamic(fn() { cls.get() }))],
  []
)
```

### Conditional Rendering

```moonbit
// show: render only when condition is true
let visible = @signals.signal(true)
let conditional : Node[Unit, String] = show(
  fn() { visible.get() },
  fn() { text("Visible") }
)

// switch: multiple condition branches
let state = @signals.signal(1)
let switched : Node[Unit, String] = switch_(
  cases=[
    match_case(when=fn() { state.get() == 1 }, render=fn() { text("State 1") }),
    match_case(when=fn() { state.get() == 2 }, render=fn() { text("State 2") }),
  ],
  fallback=Some(fn() { text("Other") })
)
```

### List Rendering

```moonbit
let items = @signals.signal(["Apple", "Banana", "Cherry"])
let list : Node[Unit, String] = for_each(fn() {
  items.get().map(fn(item) { h("li", [], [text(item)]) })
})
```

### Fragment

```moonbit
// Group multiple nodes without a wrapper element
let frag : Node[Unit, String] = fragment([
  text("Hello"),
  text(" "),
  text("World")
])
```

### Component

```moonbit
fn button(label : String) -> Node[Unit, String] {
  component(fn() {
    h("button", [("class", attr_static("btn"))], [text(label)])
  })
}
```

### Event Handler

```moonbit
let on_click : EventHandler[DomEvent] = handler(fn(e) {
  // handle event
})

let btn : Node[DomEvent, String] = h(
  "button",
  [("onclick", attr_handler(on_click))],
  [text("Click me")]
)
```

## AsyncState

Represents async operation state:

```moonbit
pub enum AsyncState[T] {
  Pending
  Success(T)
  Failure(String)
}

let state : AsyncState[User] = Pending
state.is_pending()  // true
state.value()       // None

let loaded : AsyncState[User] = Success(user)
loaded.value()      // Some(user)
```

## Node Types

| Type | Description |
|------|-------------|
| `Element` | HTML element with tag, attrs, children |
| `Text` | Static text content |
| `DynamicText` | Text from getter function |
| `Fragment` | Group of nodes |
| `Show` | Conditional rendering |
| `For` | List rendering |
| `Component` | Lazy-evaluated component |
| `Async` | Async content with fallback |
| `ErrorBoundary` | Error catching wrapper |
| `Switch` | Multi-case conditional |
| `RawHtml` | Unescaped HTML string |
