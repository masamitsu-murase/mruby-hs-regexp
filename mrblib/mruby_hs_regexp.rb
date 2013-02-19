class HsRegexp
  ESCAPE_LIST = {
    '0x0a' => '\n', '0x09' => '\t',
    '0x0d' => '\r', '0x0c' => '\f',
    '0x20' => '\0x20', '#' => '\#',
    '$' => '\$', '(' => '\(',
    ')' => '\)', '*' => '\*',
    '+' => '\+', '-' => '\-',
    '.' => '\.', '?' => '\?',
    '[' => '\[', '}' => '\}',
    ']' => '\]', '^' => '\^',
    '{' => '\{', '|' => '\|'
  }

  # ISO 15.2.15.6.1
  def self.compile(*args)
    self.new(*args)
  end

  # ISO 15.2.15.6.2
  def self.escape(str)
    tmp = str.gsub '\\', '\\\\'
    ESCAPE_LIST.each { |k, v| tmp = tmp.gsub(k, v) }
    tmp
  end

  # ISO 15.2.15.6.4
  class << self
    alias :quote :escape
  end

  # 15.2.15.6.3
  def self.last_match
    return @last_match
  end

  # ISO 15.2.15.7.8
  attr_reader :source

  # ISO 15.2.15.7.4
  def ===(str)
    return self.match(str) ? true : false
  end

  # ISO 15.2.15.7.5
  def =~(str)
    m = self.match(str)
    return m ? m.begin(0) : nil
  end

  # ISO 15.2.15.7.8
  attr_reader :source
end

class HsMatchData
  # ISO 15.2.16.3.11
  attr_reader :string

  def initialize
    @data = []
    @string = ""
  end

  def push(beg = nil, len = nil)
    if (beg && len)
      @data.push(beg: beg, len: len)
    else
      @data.push(nil)
    end
  end

  # ISO 15.2.16.3.1
  def [](index)
    d = @data[index]
    return (d && @string.slice(d[:beg], d[:len]))
  end

  # ISO 15.2.16.3.2
  def begin(index)
    d = @data[index]
    return (d && d[:beg])
  end

  # ISO 15.2.16.3.4
  def end(index = 0)
    d = @data[index]
    return (d && (d[:beg] + d[:len]))
  end

  # ISO 15.2.16.3.7
  def offset(index)
    d = @data[index]
    return (d && [ d[:beg], d[:beg] + d[:len] ])
  end

  # ISO 15.2.16.3.8
  def post_match
    d = @data[0]
    return @string.slice(d[:beg] + d[:len] .. -1)
  end

  # ISO 15.2.16.3.9
  def pre_match
    return @string.slice(0, @data[0][:beg])
  end

  # ISO 15.2.16.3.13
  def to_s
    return self[0]
  end
end
