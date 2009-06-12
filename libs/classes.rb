class Regexp
  def self.block b
    new('\{block: ' + b + ' \} (.+?) \{\/block: ' + b + ' \}',Regexp::MULTILINE+Regexp::EXTENDED)
  end
end

class Fixnum
  def odd?
    self.divmod(2)[1] == 1
  end
end

class String
  def block_split b
    reg = Regexp.block b
    foo = Hash.new
    bar = self.split(reg)
    return bar unless bar.size == 3
    foo[:pre], foo[:body], foo[:post] = bar
    return foo
  end
  
  def t_replace block_name, value
    reg = Regexp.new '\{'+block_name+'\}'
    value ||= ''
    self.gsub! reg, "#{value}"
  end
  
  def swap_block block_name, value=nil
    b = Block.new self, block_name, value
    replace b.processed
  end
end