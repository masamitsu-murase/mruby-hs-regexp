
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

