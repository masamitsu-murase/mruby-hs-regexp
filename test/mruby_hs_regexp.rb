
# Constant
assert("HsRegexp::CONSTANT") do
  HsRegexp::IGNORECASE == 1 and HsRegexp::MULTILINE == 2
end


# Class method
assert("HsRegexp.new") do
  HsRegexp.new(".*") and HsRegexp.new(".*", HsRegexp::MULTILINE)
end

# Instance method
assert("HsRegexp#==") do
  reg1 = reg2 = HsRegexp.new("(https?://[^/]+)[-a-zA-Z0-9./]+")
  reg3 = HsRegexp.new("(https?://[^/]+)[-a-zA-Z0-9./]+")
  reg4 = HsRegexp.new("(https://[^/]+)[-a-zA-Z0-9./]+")

  reg1 == reg2 and reg1 == reg3 and !(reg1 == reg4)
end

assert("HsRegexp#===") do
  reg = HsRegexp.new("(https?://[^/]+)[-a-zA-Z0-9./]+")
  (reg === "http://example.com") == true and (reg === "htt://example.com") == false
end

# TODO =~

assert("HsRegexp#casefold?") do
  reg1 = HsRegexp.new("(https?://[^/]+)[-a-zA-Z0-9./]+", HsRegexp::MULTILINE)
  reg2 = HsRegexp.new("(https?://[^/]+)[-a-zA-Z0-9./]+", HsRegexp::IGNORECASE)
  reg3 = HsRegexp.new("(https?://[^/]+)[-a-zA-Z0-9./]+", HsRegexp::MULTILINE | HsRegexp::IGNORECASE)
  reg4 = HsRegexp.new("(https?://[^/]+)[-a-zA-Z0-9./]+")
  reg5 = HsRegexp.new("(https?://[^/]+)[-a-zA-Z0-9./]+", true)

  reg1.casefold? == false and reg2.casefold? == true and reg3.casefold? == true and
    reg4.casefold? == false and reg5.casefold? == true
end

assert("HsRegexp#match") do
  reg = HsRegexp.new("(https?://[^/]+)[-a-zA-Z0-9./]+")
  reg.match("http://masamitsu-murase.12345/hoge.html") and
    reg.match("http:///masamitsu-murase.12345/hoge.html").nil?
end

assert("HsRegexp#source") do
  str = "(https?://[^/]+)[-a-zA-Z0-9./]+"
  reg = HsRegexp.new(str)

  reg.source == str
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
    [ HsRegexp.new("0x[a-f]+", HsRegexp::IGNORECASE), "00XaBCdefG", "0XaBCdef" ],
    [ HsRegexp.new("0x[^c-f]+", HsRegexp::IGNORECASE), "00XaBCdefG", "0XaB" ]
  ]

  patterns.all?{ |reg, str, result| reg.match(str)[0] == result }
end

