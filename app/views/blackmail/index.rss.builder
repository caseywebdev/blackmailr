xml.instruct!
xml.rss version: '2.0' do
  xml.channel do
    xml.title 'Blackmailr'
    xml.link 'http://blackmailr.herokuapp.com/'
    xml.description "See who's been exposed recently."
    @blackmail.each do |blackmail, i|
      xml.item do
        xml.title "#{blackmail.title}"
        xml.link "http://blackmailr.herokuapp.com/#b-#{blackmail.id}"
        xml.description "<img src='http://blackmailr.herokuapp.com/blackmail/#{blackmail.id}/image'><br>#{blackmail.description}"
        xml.pubDate blackmail.expired_at
      end
    end
  end
end
