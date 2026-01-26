// HTML/Attribute/JS String Escaping Utilities
//
// Cross-platform implementation with target-specific optimizations:
// - JS target: Uses optimized buffered escaping
// - WASM/Native: Pure MoonBit implementation

// =============================================================================
// HTML Escaping - Public API
// =============================================================================

///|
/// Check if string needs HTML escaping
pub fn needs_html_escape(s : String) -> Bool {
  for char in s {
    match char {
      '&' | '<' | '>' | '"' | '\'' => return true
      _ => ()
    }
  }
  false
}

///|
/// Escape HTML special characters and write to StringBuilder
pub fn escape_html_to(sb : StringBuilder, s : String) -> Unit {
  escape_html_to_internal(sb, s)
}

///|
/// Escape HTML and return new string
pub fn escape_html(s : String) -> String {
  escape_html_internal(s)
}

// =============================================================================
// Attribute Escaping - Public API
// =============================================================================

///|
/// Check if string needs attribute escaping (subset of HTML)
pub fn needs_attr_escape(s : String) -> Bool {
  for char in s {
    match char {
      '&' | '"' => return true
      _ => ()
    }
  }
  false
}

///|
/// Escape attribute value and write to StringBuilder
pub fn escape_attr_to(sb : StringBuilder, s : String) -> Unit {
  escape_attr_to_internal(sb, s)
}

///|
/// Escape attribute and return new string
pub fn escape_attr(s : String) -> String {
  escape_attr_internal(s)
}

// =============================================================================
// JavaScript String Escaping - Public API
// =============================================================================

///|
/// Escape JS string for embedding in script tags
pub fn escape_js_string(s : String) -> String {
  escape_js_string_internal(s)
}

///|
/// Escape JS string and write to StringBuilder
pub fn escape_js_string_to(sb : StringBuilder, s : String) -> Unit {
  escape_js_string_to_internal(sb, s)
}

// =============================================================================
// Void Element Check
// =============================================================================

///|
/// Check if HTML tag is a void (self-closing) element
pub fn is_void_element(tag : String) -> Bool {
  let len = tag.length()
  if len < 2 || len > 6 {
    return false
  }
  match len {
    2 => tag == "br" || tag == "hr"
    3 => tag == "img" || tag == "col" || tag == "wbr"
    4 => tag == "area" || tag == "base" || tag == "link" || tag == "meta"
    5 => tag == "embed" || tag == "input" || tag == "track" || tag == "param"
    6 => tag == "source" || tag == "keygen"
    _ => false
  }
}
