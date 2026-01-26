// Non-JS Target Implementation - Pure MoonBit for WASM and Native

///|
fn escape_html_internal(s : String) -> String {
  let len = s.length()
  if len == 0 {
    return s
  }
  let mut first_escape = -1
  let mut i = 0
  for char in s {
    let code = char.to_int()
    if code == 38 || code == 60 || code == 62 || code == 34 || code == 39 {
      first_escape = i
      break
    }
    i = i + 1
  }
  if first_escape < 0 {
    return s
  }
  let sb = StringBuilder::new(size_hint=len + 16)
  if first_escape > 0 {
    sb.write_string(s.unsafe_substring(start=0, end=first_escape))
  }
  i = 0
  for char in s {
    if i >= first_escape {
      let code = char.to_int()
      match code {
        38 => sb.write_string("&amp;")
        60 => sb.write_string("&lt;")
        62 => sb.write_string("&gt;")
        34 => sb.write_string("&quot;")
        39 => sb.write_string("&#39;")
        _ => sb.write_char(char)
      }
    }
    i = i + 1
  }
  sb.to_string()
}

///|
fn escape_html_to_internal(sb : StringBuilder, s : String) -> Unit {
  for char in s {
    let code = char.to_int()
    match code {
      38 => sb.write_string("&amp;")
      60 => sb.write_string("&lt;")
      62 => sb.write_string("&gt;")
      34 => sb.write_string("&quot;")
      39 => sb.write_string("&#39;")
      _ => sb.write_char(char)
    }
  }
}

///|
fn escape_attr_internal(s : String) -> String {
  let len = s.length()
  if len == 0 {
    return s
  }
  let mut first_escape = -1
  let mut i = 0
  for char in s {
    let code = char.to_int()
    if code == 38 || code == 34 {
      first_escape = i
      break
    }
    i = i + 1
  }
  if first_escape < 0 {
    return s
  }
  let sb = StringBuilder::new(size_hint=len + 8)
  if first_escape > 0 {
    sb.write_string(s.unsafe_substring(start=0, end=first_escape))
  }
  i = 0
  for char in s {
    if i >= first_escape {
      let code = char.to_int()
      match code {
        38 => sb.write_string("&amp;")
        34 => sb.write_string("&quot;")
        _ => sb.write_char(char)
      }
    }
    i = i + 1
  }
  sb.to_string()
}

///|
fn escape_attr_to_internal(sb : StringBuilder, s : String) -> Unit {
  for char in s {
    let code = char.to_int()
    match code {
      38 => sb.write_string("&amp;")
      34 => sb.write_string("&quot;")
      _ => sb.write_char(char)
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
  for char in s {
    match char {
      '\\' => sb.write_string("\\\\")
      '"' => sb.write_string("\\\"")
      '\n' => sb.write_string("\\n")
      '\r' => sb.write_string("\\r")
      '\t' => sb.write_string("\\t")
      '<' => sb.write_string("\\u003c")
      '>' => sb.write_string("\\u003e")
      _ => sb.write_char(char)
    }
  }
}
