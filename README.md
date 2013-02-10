mruby-hs-regexp
=========

This mrbgem provides Henry Spencer's regular expression.

# Example
```ruby
reg = HsRegexp.new("(https?://[^/]+)[-a-zA-Z0-9./]+")
str = "You can download mruby's source code from 'https://github.com/mruby/mruby'."

match_data = reg.match(str)
puts match_data[0]  # whole url.
  # => https://github.com/mruby/mruby
puts match_data[1]  # domain
  # => https://github.com
```

# License

BSD license.

