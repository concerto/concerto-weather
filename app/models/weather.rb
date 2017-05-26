class Weather < DynamicContent
  DISPLAY_NAME = 'Weather'.freeze

  UNITS = {
    'metric' => 'Celsius',
    'imperial' => 'Fahrenheit'
  }.freeze

  FONTS = {
    'owf' => 'Open Weather Font',
    'wi' => 'Weather Icons'
  }.freeze

  FORECAST = {
    'realtime' => 'Realtime Weather',
    'forecast' => 'Max and Min temps forecast for the day',
    'nextday' => 'Max and Min temps forecast for the next day'
  }.freeze

  validate :validate_config

  def build_content
    require 'json'
    require 'net/http'

    # initialize replacement vars incase they are net set by the chosen forecast
    format_city = ''
    format_current = ''
    format_high = ''
    format_icon = ''
    format_iconid = ''
    format_low = ''

    forecast_type = self.config['forecast_type']
    format_string = self.config['format_string']
    font_name = self.config['font_name']

    # set command api parameters
    params = {
      lat: self.config['lat'],
      lon: self.config['lng'],
      units: self.config['units'],
      mode: 'json',
      appid: ConcertoConfig['open_weather_map_api_key']
    }

    if forecast_type == 'forecast' || forecast_type == 'nextday'
      if forecast_type == 'forecast'
        title = "Today's"
        params[:cnt] = 1
      else
        title = "Tomorrow's"
        params[:cnt] = 2
      end

      url = "http://api.openweathermap.org/data/2.5/forecast/daily?#{params.to_query}"
      response = Net::HTTP.get_response(URI.parse(url)).body
      data = JSON.parse(response)

      # if there was an error, then return nil
      if data['cod'].present? && !data['cod'].to_s.starts_with?('2')
        Rails.logger.error("response (#{url}) =  #{response}")
        return nil
      end

      # Build HTML using API data
      self.config["location_name"] = data["city"]["name"]
      format_city = data['city']['name']
      format_iconid = "#{data['list'].last['weather'][0]['id']}"
      if font_name == 'wi'
        format_icon = "<i style=\'font-size:calc(min(80vh,80vw));' class=\'wi wi-owm-#{format_iconid}\'></i>"
      else
        format_icon = "<i class=\'owf owf-#{format_iconid} owf-5x\'></i>"
      end
      format_high = "#{data['list'].last['temp']['max'].round(0)} &deg;#{UNITS[params[:units]][0]}"
      format_low = "#{data['list'].last['temp']['min'].round(0)} &deg;#{UNITS[params[:units]][0]}"

      # the Redcarpet gem will assume leading spaces indicate an indented code block
      default_html = "
<h1> #{forecast_type == 'forecast' ? 'Today' : 'Tomorrow'} in #{format_city} </h1>
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

      title = 'Current'
      url = "http://api.openweathermap.org/data/2.5/weather?#{params.to_query}"
      response = Net::HTTP.get_response(URI.parse(url)).body
      data = JSON.parse(response)

      # if there was an error, then return nil
      if data['cod'].present? && !data['cod'].to_s.starts_with?('2')
        Rails.logger.error("response (#{url}) =  #{response}")
        return nil
      end

      # Build HTML using API data
      self.config["location_name"] = data["name"]

      format_city = data['name']
      format_iconid = "#{data['weather'][0]['id']}"
      if font_name == 'wi'
        format_icon = "<i style=\'font-size:calc(min(80vh,80vw));' class=\'wi wi-owm-#{format_iconid}\'></i>"
      else
        format_icon = "<i class=\'owf owf-#{format_iconid} owf-5x\'></i>"
      end
      format_high = "#{data['main']['temp_max'].round(0)} &deg;#{UNITS[params[:units]][0]}"
      format_low = "#{data['main']['temp_min'].round(0)} &deg;#{UNITS[params[:units]][0]}"
      format_current = "#{data['main']['temp'].round(0)} &deg;#{UNITS[params[:units]][0]}"

      # the Redcarpet gem will assume leading spaces indicate an indented code block
      default_html = "
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

    if format_string.blank?
      result_html = default_html
    else
      result_html = format_string
      result_html.sub! '#{format_city}', format_city
      result_html.sub! '#{format_iconid}', format_iconid
      result_html.sub! '#{format_icon}', format_icon
      result_html.sub! '#{format_high}', format_high
      result_html.sub! '#{format_low}', format_low
      result_html.sub! '#{format_current}', format_current
    end

    # Create HtmlText content
    htmltext = HtmlText.new
    htmltext.name = "#{title} weather in #{format_city}"
    htmltext.data = result_html

    [htmltext]
  end

  # Weather needs a location.  Also allow specification of units
  def self.form_attributes
    attributes = super()
    attributes.concat([config: [:lat, :lng, :units, :font_name, :location_name, :format_string, :forecast_type]])
  end

  def validate_config
    errors.add(:base, 'A city must be selected') if self.config['lat'].blank? || self.config['lng'].blank?
  end
end
