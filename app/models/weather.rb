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

  FORECAST = {
    'realtime' => 'Realtime Weather',
    'forecast' => 'Max and Min temps forecast for the day'
  }

  def build_content
    require 'json'
    require 'net/http'

    forecast_type = self.config['forecast_type']
    font_name = self.config['font_name']

    if forecast_type == 'forecast'
       # Full day forecast
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
    
       self.config["location_name"] = data["city"]["name"]

       format_city = data['city']['name']
       format_iconid = "#{data['list'][0]['weather'][0]['id']}"

       format_high = "#{data['list'][0]['temp']['max'].round(0)} &deg;#{UNITS[params[:units]][0]}"
       format_low = "#{data['list'][0]['temp']['min'].round(0)} &deg;#{UNITS[params[:units]][0]}"
       emptyhtml = "
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
       # We're using realtime weather forecast
       # Build request url
       params = {
          lat: self.config['lat'],
          lon: self.config['lng'],
          units: self.config['units'],
          mode: 'json',
          appid: ConcertoConfig['open_weather_map_api_key']
       }

       url = "http://api.openweathermap.org/data/2.5/weather?#{params.to_query}"

       # Make request to OpenWeatherMapAPI
       response = Net::HTTP.get_response(URI.parse(url)).body
       data = JSON.parse(response)

       # Build HTML using API data

       self.config["location_name"] = data["name"]

       format_city = data['name']
       format_iconid = "#{data['weather'][0]['id']}"

       format_high = "#{data['main']['temp_max'].round(0)} &deg;#{UNITS[params[:units]][0]}"
       format_low = "#{data['main']['temp_min'].round(0)} &deg;#{UNITS[params[:units]][0]}"
       format_current = "#{data['main']['temp'].round(0)} &deg;#{UNITS[params[:units]][0]}"
       emptyhtml = "
                <h1> Today in #{format_city} </h1>
                <div style='float: left; width: 50%'>
                   #{format_icon}
                </div>
                <div style='float: left; width: 50%'>
                  <p> Current </p>
                  <h1> #{format_current} </h1>
                </div>
              "

    end


    if font_name=='wi'
       format_icon = "<i style=\'font-size:100vh;' class=\'wi wi-owm-#{format_iconid}\'></i>"
    else
       format_icon = "<i class=\'owf owf-#{format_iconid} owf-5x\'></i>"
    end

    format_string = self.config['format_string']

    if format_string.blank? 
       rawhtml = empty_html
    else 
       rawhtml = eval("\"" + format_string + "\"")
    end

    # Create HtmlText content
    htmltext = HtmlText.new()
    htmltext.name = "Today's weather in #{format_city}"
    htmltext.data = rawhtml
    return [htmltext]
  end

  # Weather needs a location.  Also allow specification of units
  def self.form_attributes
    attributes = super()
    attributes.concat([:config => [:lat, :lng, :units, :font_name, :location_name, :format_string, :forecast_type]])
  end
end
