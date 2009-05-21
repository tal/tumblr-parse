=begin
  TODO:
    Make permalink, tag, search pages subclasses
    Fix audio posts
    Adjust swap_block to allow for multiple captures using array rather than hash
    
  Someday Maybe:
    Add module to pull your posts from tumblr to generate file
    Change parsing engine to grab any block and process rather than looking for blocks to process
=end


class Content
  POST_TYPES = %w{Photo Quote Link Text Chat Audio Video Regular Conversation}
  ICON_SIZES = [16,24,30,40,48,64,96,128]
  class << self
    
    def chat
      [{:label => 'Tourist',
        :line  => 'Could you give us directions to Olive Garden?'},
       {:label => 'New Yorker',
        :line  => 'No, but I could give you directions to an actual Italian restaurant.'},
       {:label => nil,
        :line  => "This line has no label for who said it."}]
    end
    
    def short_string
      "<p>This is a short little piece of <a href="">text</a></p>"
    end
    
    def long_string
      %{<p>
        Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
      </p>
      <p><a href="">username</a></p>
      <blockquote>
        <p>
          Some Text goes here.
        </p>
        <blockquote>
          <p>
            Nested blockquote
          </p>
          <p>
            Inside paragraphs
          </p>
        </blockquote>
      </blockquote>
      <p>
        More text right here
      </p>
      <blockquote>short quote</blockquote>}
    end
  
    def audio_player color
      foo = %{<script src="/javascript/tumblelog.js" language="javascript" type="text/javascript"/><span id="audio_player_56822846"><div class="audio_player"><embed width="207" height="27" quality="best" src="http://arrow-theme.tumblr.com/swf/audio_player.swf?audio_file=http://www.tumblr.com/audio_file/56822846/v1GKDlMseflhlv4hhW4wuXkK&amp;color=#{color}" type="application/x-shockwave-flash"/></div></span><script type="text/javascript">replaceIfFlash9("audio_player_56822846",'<div class="audio_player"><embed type="application/x-shockwave-flash" src="http://arrow-theme.tumblr.com/swf/audio_player.swf?audio_file=http://www.tumblr.com/audio_file/56822846/v1GKDlMseflhlv4hhW4wuXkK&color=#{color}" height="27" width="207" quality="best"></embed></div>')</script>}
    end

    def video_player size
      height = (size*0.84).to_i
      foo = %{<object width="#{size}" height="#{height}"><param value="http://www.youtube.com/v/D0wvkkWdQqg&amp;rel=0&amp;egm=0&amp;showinfo=0&amp;fs=1" name="movie"/><param value="transparent" name="wmode"/><param value="true" name="allowFullScreen"/><embed width="#{size}" height="#{height}" wmode="transparent" allowfullscreen="true" type="application/x-shockwave-flash" src="http://www.youtube.com/v/D0wvkkWdQqg&amp;rel=0&amp;egm=0&amp;showinfo=0&amp;fs=1"/></object>}
    end

    def icon size
      "http://assets.tumblr.com/images/default_avatar_#{size.to_i}.gif"
    end
    
    def short_quote
      {:quote  => 'Short Quote',
       :source => nil}
    end
    
    def medium_quote
      {:quote  => 'It does not matter how slow you go so long as you do not stop.',
       :source => 'Confucious'}
    end
    
    def long_quote
      {:quote  => %{<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>
      <p>Second Paragraph. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>},
       :source => '<p>Some Person (via <a href="#">someone</a>)</p><p>Second Paragraph</p>'}
    end
    
    def following
      people = Array.new
      10.times do |n|
        hash = {'FollowedName' => "username-#{n}",
                'FollowedTitle' => "this is some title that's really long number #{n}",
                'FollowedURL' => 'http://some.site.com/'}
        ICON_SIZES.each do |i|
          hash["FollowedPortraitURL-#{i}"] = icon i
        end
        people << hash
      end
      people
    end
    
    def notes prefs={}
      prefs={:likes=>5,:reblogs=>2,:answers=>2}.merge(prefs)
      
      all_notes=Array.new
      
      prefs[:likes].times {all_notes << like}
      (prefs[:reblogs]/2).to_i.times {all_notes << reblog(true);all_notes << reblog(false)}
      prefs[:answers].times {all_notes << answer}
      
      foo = %{<ol class="notes">}
      all_notes.each {|s| foo+= s}
      foo+= %{</ol>}
    end
    
    private
    
    def like
      foo=%{<li class="note answer tumblog_answer without_commentary">
              <a title="test" href="http://test.tumblr.com"><img title="avatar" alt="" src="#{icon(16)}" /></a>
              <span class="action"><a title="complex" class="tumblelog" href="http://complex.tumblr.com/">complex</a>
                liked this
              </span>
              <div class="clear"></div>
            </li>}
    end
    
    def reblog commentary=true
      foo=%{<li class="note reblog tumblog_test with#{'out' unless commentary}_commentary">
              <a title="test" href="http://test.tumblr.com"><img title="avatar" alt="" src="#{icon(16)}" /></a>
              <span class="action"><a title="complex" class="tumblelog" href="http://complex.tumblr.com/">complex</a>
                reblogged this from
                <a title="Word Journal" class="source_tumblelog" href="http://wordjournal.tumblr.com/">wordjournal</a>}
                
      foo+=%{    and added:} if commentary
      foo+=%{</span>
              <div class="clear"></div>
            }
      return foo+"</li>" unless commentary
      
      foo+=%{<blockquote><a title="View Post" href="http://test.tumblr.com/"> This is a short sentence which has info about the commentary</a></blockquote>
        </li>}
        
      return foo
    end
    
    def answer
      foo=%{<li class="note answer tumblog_answer without_commentary">
              <a title="test" href="http://test.tumblr.com"><img title="avatar" alt="" src="#{icon(16)}" /></a>
              <span class="action"><a title="complex" class="tumblelog" href="http://complex.tumblr.com/">complex</a>
                answered:
                <span class="answer_content"> An answer</span>
              </span>
              <div class="clear"></div>
            </li>}
    end
    
  end
end

SHORT_DESCRIPTION = Content.short_string

DESCRIPTION = Content.long_string

QUOTES = {'short' => Content.short_quote,
          'medium'=> Content.medium_quote,
          'long'  => Content.long_quote}

LINES = Content.chat

TAGS1={'Tag1'=>'#tag1', 'Tag One'=>'#tag1', 'Tag two'=>'#tag2'}
TAGS2={'Tag1'=>'#tag1', 'An Additional long tag'=>'#', 'Tag two'=>'#tag2', 'Tag two'=>'#tag2', 'Tag two'=>'#tag2', 'Tag two'=>'#tag2', 'Tag two'=>'#tag2', 'Tag two'=>'#tag2', 'Tag two'=>'#tag2'}

following = Array.new

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

class Post
  attr_accessor :contents, :type, :time
  def initialize text
    @contents = text.dup
    @time = nil
    @type = nil
  end
  
  def swap_block block_name, value=nil
    @contents.swap_block block_name, value
  end

  def text options={:title=>true,:body=>true,:long=>true}
    filter
    
    if options[:title] == true
      title = 'This is a text tile'
    elsif options[:title]
      title = options[:title]
    else
      title = nil
    end
    
    @contents.swap_block 'Title', title
    @contents.t_replace 'Body', set_description(:body, options)
    return self
  end#text
  alias :regular :text
  
  def photo options={:caption=>true,:long=>false}
    filter
    
    %w{75sq 100 250 400 500}.each {|s| @contents.t_replace "PhotoURL-#{s}", "http://10.media.tumblr.com/2KfNZVJctk7ajzsazyox5t4do1_r1_#{s}.jpg" }
    @contents.t_replace 'LinkOpenTag', '<a href="#">'
    @contents.t_replace 'LinkOpenTag', '<a href="#">'
    @contents.t_replace 'LinkCloseTag', '</a>'
    @contents.t_replace 'LinkURL', '#'
    
    @contents.swap_block 'Caption', set_description(:caption, options)
    return self
  end#photo
  
  def quote size='medium', options={:source=>true}
    filter
    @contents.t_replace 'Length', size
    @contents.t_replace 'Quote', QUOTES[size][:quote]
    @contents.swap_block 'Source', QUOTES[size][:source]
    return self
  end#quote
  
  def link options={:name=>true,:description=>true}
    filter
    
    url   = options[:url]
    url ||= 'http://tumblr.com'
    
    if options[:name] == true || options[:name].nil?
      name = 'Tumblr.com is a cool site'
    elsif options[:name]
      name = options[:name]
    else
      name = url
    end
    
    @contents.t_replace 'Name', name
    @contents.t_replace 'URL', url
    @contents.t_replace 'Target', '_blank'
    @contents.swap_block 'Description', set_description(:description, options)
    return self
  end#link
  
  def chat options={}
    filter
    
    @contents.swap_block 'Title', replace_if_exists(:title,options,"Chat Post")
    @contents.swap_block 'Lines', Content.chat
    return self
  end#chat
  alias :conversation :chat
  
  def audio options={}
    filter
    
    @contents.swap_block 'Caption', set_description(:caption,options)
    @contents.swap_block 'ExternalAudio', replace_if_exists(:external_audio,options,"http://mp3.com")
    @contents.t_replace 'AudioPlayerGrey', Content.audio_player('E4E4E4')
    @contents.t_replace 'AudioPlayerWhite', Content.audio_player('FFFFFF')
    @contents.t_replace 'AudioPlayerBlack', Content.audio_player('000000')
    @contents.t_replace 'PlayCount', '1337'
    @contents.t_replace 'FormattedPlayCount', '1,337'
    return self
  end#audio
  
  def video options={}
    filter
    
    @contents.swap_block 'Caption', set_description(:caption,options)
    %w{500 400 250}.each {|size| @contents.t_replace "Video-#{size}", Content.video_player(size.to_i) }
    return self
  end#video
  
  def new_day_date time=Time.now
    return if self.time
    @time = time
    @contents.swap_block 'NewDayDate', true
    @contents.swap_block 'SameDayDate'
    set_time
  end#new day date
  
  def same_day_date time=(Time.now-3600)
    return if self.time
    @time = time
    @contents.swap_block 'SameDayDate', true
    @contents.swap_block 'NewDayDate'
    set_time
  end#same day date
  
  def set_time time=nil
    time ||= @time
    time ||= Time.now
    @contents.t_replace 'DayOfMonth', time.day
    @contents.t_replace 'DayOfMonthWithZero', ("%02d" % time.day )
    @contents.t_replace 'DayOfWeek', time.strftime("%A")
    @contents.t_replace 'ShortDayOfWeek', time.strftime("%a")
    @contents.t_replace 'DayOfWeekNumber', time.wday
    @contents.t_replace 'DayOfMonthSuffix', case time.day
                                            when 1: 'st'
                                            when 2: 'nd'
                                            when 3: 'rd'
                                            else    'th'
                                            end
    @contents.t_replace 'DayOfYear', time.yday
    @contents.t_replace 'WeekOfYear', time.strftime("%U")
    @contents.t_replace 'Month', time.strftime("%B")
    @contents.t_replace 'ShortMonth', time.strftime("%b")
    @contents.t_replace 'MonthNumber', time.month
    @contents.t_replace 'MonthNumberWithZero', ("%02d" % time.month)
    @contents.t_replace 'Year', time.year
    @contents.t_replace 'ShortYear', time.strftime("%y")
    @contents.t_replace 'AmPm', time.strftime("%p").upcase
    @contents.t_replace 'CapitalAmPm', time.strftime("%p")
    @contents.t_replace '12Hour', time.strftime("%I")
    @contents.t_replace '24Hour', time.strftime("%H")
    @contents.t_replace '12HourWithZero', time.strftime("%I")
    @contents.t_replace '24HourWithZero', ("%02d" % time.hour)
    @contents.t_replace 'Minutes', time.min
    @contents.t_replace 'Seconds', time.sec
    @contents.t_replace 'Beats', '666'
    @contents.t_replace 'Timestamp', '1172705619'
    @contents.t_replace 'TimeAgo', '3 weeks ago'
    return self
  end
  
  def set_note_count count=7
    count = nil if count == 0 # doesn’t display note count if there are no notes
    @contents.swap_block 'NoteCount', count
    @contents.t_replace 'NoteCountWithLabel', case count
                                              when 1: "#{count} post"
                                              else    "#{count} posts"
                                              end
    
    return self
  end
  
  def notes arg=true
    if arg == true
      text = Content.notes
    else
      text = arg
    end
    
    @contents.swap_block 'PostNotes', text
  
    return self
  end
  
  def has_tags tags=TAGS1
    @contents.swap_block 'HasTags', tags
    return self
  end#tags
  
  def is_reblog user={:title=>'Some Blog Title',:user=>'user'}
    @contents.swap_block 'RebloggedFrom', user
    unless user
      @contents.swap_block 'NotReblog', true
      @contents.swap_block 'Reblog', nil
      return
    end
    @contents.swap_block 'Reblog', true
    @contents.swap_block 'NotReblog', nil
    @contents.t_replace 'ReblogParentName', user[:user]
    @contents.t_replace 'ReblogParentTitle', user[:title]
    @contents.t_replace 'ReblogRootName', user[:user]
    @contents.t_replace 'ReblogRootTitle', user[:title]
    
    Content::ICON_SIZES.each do |s|
      @contents.t_replace "ReblogParentPortraitURL-#{s}", Content.icon(s)
      @contents.t_replace "ReblogRootPortraitURL-#{s}", Content.icon(s)
    end
    return self
  end#reblog
  
private
  def filter
    return if self.type
    @type = caller[0].match(/\`(.+)\'/i)[1].capitalize # Finds name of method which called 'filter'
    @contents.swap_block @type, true
    case @type
    when 'Text': @contents.swap_block 'Regular', true
    when 'Chat': @contents.swap_block 'Conversation', true
    end
    
    Content::POST_TYPES.each {|p| @contents.swap_block(p) unless p==@type}
  end#filter
  
  def replace_if_exists value, options, default
    if options[:value]==true || options[:value].nil?
      title = default
    elsif options[:value]
      title = options[:value]
    else
      title = nil
    end
  end
  
  def set_description value, options
    if options[value] == true
      if options[:long]
        DESCRIPTION
      else
        SHORT_DESCRIPTION
      end
    elsif options[value]
      options[value]
    else
      nil
    end#if
  end#set_description
  

  
end

if __FILE__ == $0 # exits if the script is required instead of explicitly run

  filename = ARGV[0]
  filename ||= "tumblr.txt"

  @page = Page.new filename

  @page.post.text.new_day_date.is_reblog
  @page.post.quote('short')
  @page.post.link
  @page.post.quote
  @page.post.quote('long').has_tags.new_day_date
  @page.post.audio(:caption => SHORT_DESCRIPTION, :external_audio => true)
  @page.post.video
  @page.post.chat
  @page.following nil
  @page.title = "my blog title"
  @page.output

end