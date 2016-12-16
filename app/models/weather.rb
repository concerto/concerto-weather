class Weather < DynamicContent
  DISPLAY_NAME = 'Weather'

  UNITS = {
    'metric' => 'Celsius',
    'imperial' => 'Fahrenheit'
  }

  FONTS = {
    'owf' => 'Open Weather Font',
    'wi' => 'Weather Icons' 
  }

  def build_content
    require 'json'
    require 'net/http'

    # Build request url
    params = {
      lat: self.config['lat'],
      lon: self.config['lng'],
      units: self.config['units'],
      cnt: 1,
      mode: 'json',
      appid: ConcertoConfig['open_weather_map_api_key']
    }

    url = "http://api.openweathermap.org/data/2.5/forecast/daily?#{params.to_query}"

    # Make request to OpenWeatherMapAPI
    response = Net::HTTP.get_response(URI.parse(url)).body
    data = JSON.parse(response)

    # Build HTML using API data
    
    font_name = self.config['font_name']
    byebug

    format_city=data['city']['name']
    format_iconid="#{data['list'][0]['weather'][0]['id']}"

    if font_name =='wi'
       format_icon="<i class=\wi wi-owm-#{format_iconid}\'></i>"
    else 
       format_icon="<i class=\'owf owf-#{format_iconid} owf-5x\'></i>"
    end
    #format_high=data['list'][0]['temp']['max']
    #format_low=data['list'][0]['temp']['min']

    format_high="#{data['list'][0]['temp']['max'].round(0)} &deg;#{UNITS[params[:units]][0]}"
    format_low="#{data['list'][0]['temp']['min'].round(0)} &deg;#{UNITS[params[:units]][0]}"

    format_string = self.config['format_string']

    if format_string.blank? 
       rawhtml = "
                <h1> Today in #{format_city} </h1>
                <div style='float: left; width: 50%'>
                   #{format_icon}
                </div>
                <div style='float: left; width: 50%'>
                  <p> High </p>
                  <h1> #{format_high} </h1>
                  <p> Low </p>
                  <h1> #{format_low}</h1>
                </div>
              "
    else 
       rawhtml = eval("\"" + format_string + "\"")
    end

    # Create HtmlText content
    htmltext = HtmlText.new()
    htmltext.name = "Today's weather in #{format_city}"
    htmltext.data = rawhtml

    self.config["location_name"] = data["city"]["name"]
    return [htmltext]
  end

  # Weather needs a location.  Also allow specification of units
  def self.form_attributes
    attributes = super()
    attributes.concat([:config => [:lat, :lng, :units, :font_name, :location_name, :format_string]])
  end
end
