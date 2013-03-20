class Weather < DynamicContent
  DISPLAY_NAME = 'Weather'

  def build_content
    require 'rss'
    require 'net/http'

    url = "http://weather.yahooapis.com/forecastrss?p=#{self.config['zip_code']}"

    feed = Net::HTTP.get_response(URI.parse(url)).body

    rss = RSS::Parser.parse(feed, false, true)

    weather_data = rss.items.first
    sanitized_data = weather_data.description
    htmltext = HtmlText.new()
    htmltext.name = weather_data.title
    htmltext.data = "<h1>#{rss.channel.title}</h1><i>#{weather_data.title}</i><p>#{sanitized_data}</p>"
    return [htmltext]
  end

  # Weather needs a location.
  def self.form_attributes
    attributes = super()
    attributes.concat([:config => [:zip_code]])
  end
end
