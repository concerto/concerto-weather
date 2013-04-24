class Weather < DynamicContent
  DISPLAY_NAME = 'Weather'

  UNITS = {
    'c' => 'Celsius',
    'f' => 'Fahrenheit'
  }

  validate :woeid_must_exist

  def build_content
    require 'rss'
    require 'net/http'

    url = "http://weather.yahooapis.com/forecastrss?w=#{self.config['woeid']}&u=#{self.config['units']}"

    feed = Net::HTTP.get_response(URI.parse(url)).body

    rss = RSS::Parser.parse(feed, false, true)

    weather_data = rss.items.first
    sanitized_data = weather_data.description
    htmltext = HtmlText.new()
    htmltext.name = weather_data.title
    rawhtml = "<h1>#{rss.channel.title}</h1><i>#{weather_data.title}</i><p>#{sanitized_data}</p>"
    Rails.logger.debug rawhtml
    htmltext.data = ActionController::Base.helpers.sanitize(rawhtml, :tags => ['i', 'img', 'b', 'br', 'p', 'h1'])
    return [htmltext]
  end

  # Weather needs a location.  Also allow specification of units
  def self.form_attributes
    attributes = super()
    attributes.concat([:config => [:woeid, :units]])
  end

  def woeid_must_exist
    if !self.config.nil?  # had to add thius because rake dynamic_content:refresh was blowing up on nil object
      if self.config['woeid'].empty?
        errors.add(:woeid, 'must be specified')
      else
        data = []
        #begin
        woeid = URI.escape(self.config['woeid'])
        url = URI.escape("http://query.yahooapis.com/v1/public/yql?q=select * from geo.places where woeid = #{woeid} limit 1&format=json")
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)
        if response.code == '200'  #ok
          json = response.body
          data = ActiveSupport::JSON.decode(json)
        end
        #rescue
        #  Rails.logger.debug("Yahoo not reachable @ #{url}.")
        #  return
        #end
        if data.empty? || data['query']['count'] == 0
          errors.add(:woeid, 'not valid')
        else
          results = data['query']['results']['place']
          info = results['name']
          info = info + ', ' + results['admin1']['content'] if !results['admin1']['content'].empty? if !results['admin1'].nil?
          info = info + ', ' + results['admin2']['content'] if !results['admin2']['content'].empty? if !results['admin2'].nil?
          info = info + ', ' + results['country']['content'] if !results['country']['content'].empty? if !results['country'].nil?
          self.config['name'] = info
        end
      end
    end
  end
end
