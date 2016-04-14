class Weather < DynamicContent
  DISPLAY_NAME = 'Weather'

  UNITS = {
    'metric' => 'Celsius',
    'imperial' => 'Fahrenheit'
  }

  def build_content
    require 'json'
    require 'net/http'

    # Build request url 
    params = {
      q: self.config['location'],
      u: self.config['units'],
      cnt: 4,
      mode: 'json',
      appid: ConcertoConfig['open_weather_map_api_key']
    }

    url = "http://api.openweathermap.org/data/2.5/forecast/daily?#{params.to_query}"

    # Make request to OpenWeatherMapAPI
    response = Net::HTTP.get_response(URI.parse(url)).body
    data = JSON.parse(response)
    
    # Build HTML using API data
    rawhtml = ""

    # Create HtmlText content
    htmltext = HtmlText.new()
    htmltext.name = "Today's weather in #{data['city']['name']}"
    htmltext.data = ActionController::Base.helpers.sanitize(rawhtml, :tags => ['i', 'img', 'b', 'br', 'p', 'h1'])

    return [htmltext]
  end

  # Weather needs a location.  Also allow specification of units
  def self.form_attributes
    attributes = super()
    attributes.concat([:config => [:location, :units]])
  end
end