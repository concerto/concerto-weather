class Weather < DynamicContent
  DISPLAY_NAME = 'Weather'

  UNITS = {
    'metric' => 'Celsius',
    'imperial' => 'Fahrenheit'
  }

  def build_content
    require 'erb'
    require 'json'
    require 'net/http'

    # Build request url 
    params = {
      q: self.config['location'],
      units: self.config['units'],
      cnt: 4,
      mode: 'json',
      appid: ConcertoConfig['open_weather_map_api_key']
    }

    url = "http://api.openweathermap.org/data/2.5/forecast/daily?#{params.to_query}"

    # Make request to OpenWeatherMapAPI
    response = Net::HTTP.get_response(URI.parse(url)).body
    data = JSON.parse(response)
    
    # Build HTML using API data
    rawhtml = "
                <h1> Today in #{data['city']['name']} </h1>
                <div style='float: left; width: 50%'>
                  <img src='http://api.openweathermap.org/img/w/#{data['list'][0]['weather'][0]['icon']}' />
                </div>
                <div style='float: left; width: 50%'>
                  <p> High </p>
                  <h1> #{data['list'][0]['temp']['max']} &deg;#{UNITS[params[:units]][0]}</h1>
                  <p> Low </p>
                  <h1> #{data['list'][0]['temp']['min']} &deg;#{UNITS[params[:units]][0]}</h1>
                </div>
              "

    # Create HtmlText content
    htmltext = HtmlText.new()
    htmltext.name = "Today's weather in #{data['city']['name']}"
    htmltext.data = rawhtml

    return [htmltext]
  end

  # Weather needs a location.  Also allow specification of units
  def self.form_attributes
    attributes = super()
    attributes.concat([:config => [:location, :units]])
  end
end