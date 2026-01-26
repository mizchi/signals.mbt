// JS Target Implementation - Optimized buffered escaping

///|
fn escape_html_internal(s : String) -> String {
  let len = s.length()
  if len == 0 {
    return s
  }
  let mut needs_escape = false
  for char in s {
    let code = char.to_int()
    if code == 38 || code == 60 || code == 62 || code == 34 || code == 39 {
      needs_escape = true
      break
    }
  }
  if not(needs_escape) {
    return s
  }
  let sb = StringBuilder::new(size_hint=len + 16)
  escape_html_to_internal(sb, s)
  sb.to_string()
}

///|
fn escape_html_to_internal(sb : StringBuilder, s : String) -> Unit {
  let len = s.length()
  if len == 0 {
    return
  }
  let mut start = 0
  let mut i = 0
  for char in s {
    let code = char.to_int()
    let escape_seq : String? = match code {
      38 => Some("&amp;")
      60 => Some("&lt;")
      62 => Some("&gt;")
      34 => Some("&quot;")
      39 => Some("&#39;")
      _ => None
    }
    match escape_seq {
      Some(seq) => {
        if i > start {
          sb.write_string(s.unsafe_substring(start~, end=i))
        }
        sb.write_string(seq)
        start = i + 1
      }
      None => ()
    }
    i = i + 1
  }
  if start < len {
    if start == 0 {
      sb.write_string(s)
    } else {
      sb.write_string(s.unsafe_substring(start~, end=len))
    }
  }
}

///|
fn escape_attr_internal(s : String) -> String {
  let len = s.length()
  if len == 0 {
    return s
  }
  let mut needs_escape = false
  for char in s {
    let code = char.to_int()
    if code == 38 || code == 34 {
      needs_escape = true
      break
    }
  }
  if not(needs_escape) {
    return s
  }
  let sb = StringBuilder::new(size_hint=len + 8)
  escape_attr_to_internal(sb, s)
  sb.to_string()
}

///|
fn escape_attr_to_internal(sb : StringBuilder, s : String) -> Unit {
  let len = s.length()
  if len == 0 {
    return
  }
  let mut start = 0
  let mut i = 0
  for char in s {
    let code = char.to_int()
    let escape_seq : String? = match code {
      38 => Some("&amp;")
      34 => Some("&quot;")
      _ => None
    }
    match escape_seq {
      Some(seq) => {
        if i > start {
          sb.write_string(s.unsafe_substring(start~, end=i))
        }
        sb.write_string(seq)
        start = i + 1
      }
      None => ()
    }
    i = i + 1
  }
  if start < len {
    if start == 0 {
      sb.write_string(s)
    } else {
      sb.write_string(s.unsafe_substring(start~, end=len))
    }
  }
}

///|
fn escape_js_string_internal(s : String) -> String {
  let sb = StringBuilder::new(size_hint=s.length() + 16)
  escape_js_string_to_internal(sb, s)
  sb.to_string()
}

///|
fn escape_js_string_to_internal(sb : StringBuilder, s : String) -> Unit {
  let len = s.length()
  if len == 0 {
    return
  }
  let mut start = 0
  let mut i = 0
  for char in s {
    let escape_seq : String? = match char {
      '\\' => Some("\\\\")
      '"' => Some("\\\"")
      '\n' => Some("\\n")
      '\r' => Some("\\r")
      '\t' => Some("\\t")
      '<' => Some("\\u003c")
      '>' => Some("\\u003e")
      _ => None
    }
    match escape_seq {
      Some(seq) => {
        if i > start {
          sb.write_string(s.unsafe_substring(start~, end=i))
        }
        sb.write_string(seq)
        start = i + 1
      }
      None => ()
    }
    i = i + 1
  }
  if start < len {
    if start == 0 {
      sb.write_string(s)
    } else {
      sb.write_string(s.unsafe_substring(start~, end=len))
    }
  }
}
