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