
# Constant
assert("HsRegexp::CONSTANT") do
  HsRegexp::IGNORECASE == 1 and HsRegexp::MULTILINE == 2
end


assert("HsRegexp.new") do
  HsRegexp.new(".*") and HsRegexp.new(".*", HsRegexp::MULTILINE)
end

assert("HsRegexp#match") do
  reg = HsRegexp.new("(https?://[^/]+)[-a-zA-Z0-9./]+")
  reg.match("http://masamitsu-murase.12345/hoge.html") and
    reg.match("http:///masamitsu-murase.12345/hoge.html").nil?
end

# Extended patterns.
assert("HsRegexp#match (no flags)") do
  patterns = [
    [ HsRegexp.new(".*"), "abcd\nefg", "abcd" ],
    [ HsRegexp.new("^a."), "abcd\naefg", "ab" ],
    [ HsRegexp.new("^a."), "bacd\naefg", "ae" ],
    [ HsRegexp.new(".$"), "bacd\naefg", "d" ]
  ]

  patterns.all?{ |reg, str, result| reg.match(str)[0] == result }
end

assert("HsRegexp#match (multiline)") do
  patterns = [
    [ HsRegexp.new(".*", HsRegexp::MULTILINE), "abcd\nefg", "abcd\nefg" ]
  ]

  patterns.all?{ |reg, str, result| reg.match(str)[0] == result }
end

assert("HsRegexp#match (ignorecase)") do
  patterns = [
    [ HsRegexp.new("aBcD", HsRegexp::IGNORECASE), "00AbcDef", "AbcD" ],
    [ HsRegexp.new("0x[a-f]+", HsRegexp::IGNORECASE), "00XaBCdefG", "0XaBCdef" ]
  ]

  patterns.all?{ |reg, str, result| (p reg.match(str)[0]) == result }
end

