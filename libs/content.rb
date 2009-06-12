
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