mruby Henry Spencer's regular expression (mruby-hs-regexp)
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

# Overview

mruby has not supported regular example yet (on 2013-02-11).  
mruby's regular expression, oniguruma, is a great implementation, 
but I think that its size is large and too rich for embedded use.  
These are the reason why I tried to implement this mrbgem, mruby-hs-regexp.

This mrbgem provides two classes: `HsRegexp` and `HsMatchData`.  
They are similar to `Regexp` and `MatchData`, so you can use this module easily.

# Reference

## `HsRegexp`

### class methods

#### `new`
Create new instance of HsRegexp.
```ruby
reg = HsRegexp.new("(https?://[^/]+)[-a-zA-Z0-9./]+")
```
You can use the following meta-characters:

* `*`: zero or more preceding element.
* `+`: one or more preceding element.
* `?`: zero or one preceding element.
* `^`: beginning of the line
* `$`: end of the line
* `.`: one arbitrary element
* `a|b`: `a` or `b`
* `[abc]`: `a` or `b` or `c`
* `(XX)`: grouping

#### `compile`
Same as `new`

### instance methods

#### `match`
Try to match with string and return `HsMatchData` or `nil`.

```ruby
reg = HsRegexp.new("(https?://[^/]+)[-a-zA-Z0-9./]+")
str = "You can download mruby's source code from 'https://github.com/mruby/mruby'."
match_data = reg.match(str)
```
Currently, `String#match` is *not* supported.

## `HsMatchData`

### instance methods

#### `[]`
Return n-th matched string. (Same as `MatchData`).

```ruby
reg = HsRegexp.new("(https?://[^/]+)[-a-zA-Z0-9./]+")
str = "You can download mruby's source code from 'https://github.com/mruby/mruby'."
match_data = reg.match(str)
p match_data[0]
 # => "https://github.com/mruby/mruby"
p match_data[1]
 # => "https://github.com"
```

#### `begin` and `end`
Return beginning and end position of the matched data.

```ruby
reg = HsRegexp.new("cd")
str = "abcde"
m = reg.match(str)
p m.begin(0)
 # => 2
p m.end(0)
 # => 4
```

Other methods have not been implemented yet...

