class HsRegexp
end

class HsMatchData
  def initialize
    @data = []
  end

  def push(str = nil, pos = nil)
    if (str && pos)
      @data.push(str: str, pos: pos)
    else
      @data.push(nil)
    end
  end

  def begin(index = 0)
    return (@data[index] && @data[index][:pos])
  end

  def end(index = 0)
    return (@data[index] && (@data[index][:pos] + @data[index][:str].size))
  end

  def [](index)
    return (@data[index] && @data[index][:str])
  end

  def size
    return @data.size
  end
end

