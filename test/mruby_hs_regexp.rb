# Constant
assert('HsRegexp::CONSTANT', '15.2.15.3') do
  HsRegexp::IGNORECASE == 1 and HsRegexp::MULTILINE == 4
end

# Class method
assert('HsRegexp.new', '15.2.15.6.1') do
  HsRegexp.new(".*") and HsRegexp.new(".*", HsRegexp::MULTILINE)
end

assert('HsRegexp.compile', '15.2.15.6.1') do
  HsRegexp.compile(".*") and HsRegexp.compile(".*", HsRegexp::MULTILINE)
end

assert('HsRegexp.escape', '15.2.15.6.2') do
  s1 = '#$()*+?'
  s2 = '\#\$\(\)\*\+\?'

  HsRegexp.escape(s1) == s2
end

assert('HsRegexp.quote', '15.2.15.6.4') do
  s1 = '#$()*+?'
  s2 = '\#\$\(\)\*\+\?'

  HsRegexp.quote(s1) == s2
end

# Instance method
assert('HsRegexp#==', '15.2.15.7.3') do
  reg1 = reg2 = HsRegexp.new("(https?://[^/]+)[-a-zA-Z0-9./]+")
  reg3 = HsRegexp.new("(https?://[^/]+)[-a-zA-Z0-9./]+")
  reg4 = HsRegexp.new("(https://[^/]+)[-a-zA-Z0-9./]+")

  reg1 == reg2 and reg1 == reg3 and !(reg1 == reg4)
end

assert('HsRegexp#===', '15.2.15.7.4') do
  reg = HsRegexp.new("(https?://[^/]+)[-a-zA-Z0-9./]+")
  (reg === "http://example.com") == true and (reg === "htt://example.com") == false
end

assert('HsRegexp#=~', '15.2.15.7.5') do
  m1 = HsRegexp.new('abc') =~ 'abc'
  m2 = HsRegexp.new('abc') =~ '1234abc'
  m3 = HsRegexp.new('abc') =~ '1234'

  m1 == 0 and m2 == 4 and m3.nil?
end

assert('HsRegexp#casefold?', '15.2.15.7.6') do
  reg1 = HsRegexp.new("(https?://[^/]+)[-a-zA-Z0-9./]+", HsRegexp::MULTILINE)
  reg2 = HsRegexp.new("(https?://[^/]+)[-a-zA-Z0-9./]+", HsRegexp::IGNORECASE)
  reg3 = HsRegexp.new("(https?://[^/]+)[-a-zA-Z0-9./]+", HsRegexp::MULTILINE | HsRegexp::IGNORECASE)
  reg4 = HsRegexp.new("(https?://[^/]+)[-a-zA-Z0-9./]+")
  reg5 = HsRegexp.new("(https?://[^/]+)[-a-zA-Z0-9./]+", true)

  reg1.casefold? == false and reg2.casefold? == true and reg3.casefold? == true and
    reg4.casefold? == false and reg5.casefold? == true
end

assert('HsRegexp#match', '15.2.15.7.7') do
  reg = HsRegexp.new("(https?://[^/]+)[-a-zA-Z0-9./]+")
  reg.match("http://masamitsu-murase.12345/hoge.html") and
    reg.match("http:///masamitsu-murase.12345/hoge.html").nil?
end

assert('HsRegexp#source', '15.2.15.7.8') do
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
