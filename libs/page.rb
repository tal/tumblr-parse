class Page
  attr_accessor :pre,:body,:foot,:posts, :title, :description, :type, :twitter, :name
  
  def initialize filename, args={}
    values = {:type=>'index', :description => Content.long_string, :title => 'My Blog Title',:name=>'Test',:twitter=>'Koalemos'}.merge(args)
    page = File.open(filename).read
    foo   = page.block_split "Posts"
    raise "No {block:Posts} found in source file" if foo.is_a?(Array)
    @pre,@body,@foot  = foo[:pre], foo[:body], foo[:post]
    @posts = Array.new
    
    values.each do |key,value|
      instance_variable_set "@#{key}", value
    end
    
    @posts_proc = false
  end
  
  def post
    @posts << obj = Post.new(@body)
    obj
  end
  
  def finish_posts
    return if @posts_proc
    @posts_proc = true
    
    # removes blocks for reblog/tags in posts not set
    @posts.each do |p|
      p.swap_block 'FromBookmarklet'
      p.swap_block 'FromMobile'
      p.is_reblog false
      p.has_tags false
      p.same_day_date
      p.set_note_count
      p.notes
    end
      
    @body = if @type == 'permalink' 
        @pre + @posts.first.contents + @foot
      else
        @pre + @posts.collect{|p| p.contents}.join + @foot
      end
    
    # Replaces custom colors
    color_names = @body.scan(/<meta .+ name="(color:.+?)" .* \/>/ix).flatten
    color_codes = @body.scan(/<meta .+ content="(.+?)" .* \/>/ix).flatten
    colors = Hash.new
    color_names.each_index {|i| colors[color_names[i]] = color_codes[i]}
    colors.each {|name,code| @body.t_replace name, code}
    
  end
  
  def pagination args={}
    options={:next=>true,:previous=>true}.merge(args)
    finish_posts
    @body.swap_block 'Pagination', [options[:next],options[:previous]]
    @body.swap_block 'PermalinkPagination'
  end
  
  def permalink_pagination args={}
    options={:next=>true,:previous=>true}.marge(args)
    finish_posts
    @body.swap_block 'PermalinkPagination', [options[:next],options[:previous]]
    @body.swap_block 'Pagination'
  end
  
  def following people
    finish_posts
    @body.swap_block 'Following', people
  end
  
  def tag_page tag
    @body.swap_block 'TagPage', tag
    @body.swap_block 'SearchPage', nil
  end
  
  def search_page search
    @body.swap_block 'SearchPage', search
    @body.swap_block 'TagPage', nil
  end
  
  def output file='parse.html'
    finish_posts
    
    %w{ Title Name }.each {|v| @body.t_replace v, instance_variable_get("@#{v}".downcase) }
    @body.t_replace 'Permalink', 'permalink.html'
    @body.swap_block 'Twitter', @twitter
    @body.swap_block 'PostTitle', (posts.first.type if type == 'permalink')
    @body.swap_block 'Description', @description
    if @type == 'permalink'
      self.permalink_pagination
      @body.swap_block 'IndexPage', nil
      @body.swap_block 'PermalinkPage', true
    else
      self.pagination
      @body.swap_block 'PermalinkPage', nil
      @body.swap_block 'IndexPage', true
    end
    
    # removes any search or tag info if it hasn't been set yet.
    @body.t_replace 'SearchQuery', nil
    tag_page nil
    search_page nil
    
    File.open(file, 'w') {|f| f.write(@body) }
  end
end