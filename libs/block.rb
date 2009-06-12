class Block
  attr_accessor :items, :processed, :name, :value
  def initialize text, name, value=nil
    @name = name
    @value = value
    reg = Regexp.block name
    foo = Hash.new
    @items = text.split(reg)
    
    @items.each_index do |i|
      if i.odd?
        (@content||=[]) << @items[i]
      else
        (@wrapper||=[]) << @items[i]
      end
    end
    
    swap
  end
  
  def size
    items.size
  end
  
  def swap
    if size == 1 # if the block isn't found replaces {Source} if {block:Source} doesn't exist
      case value
      when String
        @items[0].t_replace(@name,@value)
      when true
        nil
      else
        @items[0].t_replace(@name,'')
      end
      self.processed = @items.join
    else
      if value
        process_block @name, @value
        self.processed = @items.join
      else
        self.processed = @wrapper.join
      end
    end
    return processed
  end#swap
  
private
  
  def process_block block_name, value
    @content.each do |c|
      case block_name
      when "HasTags" # has to be run before Tags
        c.swap_block('Tags', value)
      when "Tags"
        string = String.new
        value.each do |tag, _URL|
          temp = c.gsub(/\{Tag\}/, tag)
          temp.gsub!(/\{TagURL\}/, _URL)
          string += temp
        end
        c = string
      when "Lines"
        string = String.new
        value.each_index do |i|
          temp = String.new(c)
        
          temp.swap_block 'Label', value[i][:label]
          temp.t_replace 'Alt', i.modulo(2).to_s
          temp.t_replace 'Line', value[i][:line]
        
          string += temp
        end
        c.replace string
      when "ExternalAudio"
        c.t_replace 'ExternalAudioURL', value
      when "RebloggedFrom"
        c.t_replace 'ReblogRootURL', '#root'
        c.t_replace 'ReblogParentURL', '#parent'
      when "Pagination"
        c.t_replace 'CurrentPage', '64'
        c.t_replace 'TotalPages', '128'
        c.swap_block('NextPage',value[0])
        c.swap_block('NextPost',false)
        c.swap_block('PreviousPage',value[1])
        c.swap_block('PreviousPost',false)
      when "PermalinkPagination"
        c.t_replace 'CurrentPage', '64'
        c.t_replace 'TotalPages', '128'
        c.swap_block('NextPage',false)
        c.swap_block('NextPost',value[0])
        c.swap_block('PreviousPage',false)
        c.swap_block('PreviousPost',value[1])
      when "Following"
        c.swap_block('Followed', value)
      when "Followed"
        string = String.new
        value.each do |a|
          temp = c
          a.each do |name,content|
            temp.t_replace name, content
          end
          string += temp
        end
        c = string
      when "TagPage"
        c.t_replace 'Tag', value
      when "SearchPage"
        splitted.each_value {|s| s.t_replace 'SearchQuery', value }
      when "Twitter"
        c.t_replace 'TwitterUsername', value
      else
        unless value == true
          c.t_replace block_name, value
        end
      end#case
    end#each-content
  end
  
end