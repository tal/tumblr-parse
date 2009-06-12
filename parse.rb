require 'libs/classes.rb'
require 'libs/content.rb'
require 'libs/block.rb'
require 'libs/page.rb'
require 'libs/post.rb'

if __FILE__ == $0 # exits if the script is required instead of explicitly run

  filename = ARGV[0]
  filename ||= "default.txt"

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