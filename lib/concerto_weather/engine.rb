module ConcertoWeather
  class Engine < ::Rails::Engine
    isolate_namespace ConcertoWeather

    initializer "register content type" do |app|
      app.config.content_types << Weather
    end

    initializer "weather.assets.precompile" do |app|
      app.config.assets.precompile += %w(application.css application.js)
    end

    def plugin_info(plugin_info_class)
      @plugin_info ||= plugin_info_class.new do
        add_route("concerto_weather", ConcertoWeather::Engine)

        add_config("open_weather_map_api_key", "",
                   value_type: "string",
                   category: "API Keys",
                   description: "OpenWeatherMap API Access Token. This token is used for obtaining weather information when adding weather content. http://openweathermap.org/appid")

        # Add owfont (open weather) icon set to application layout for content preview / browsing
        add_header_tags do
          stylesheet_link_tag "assets/concerto_weather/application.css"
        end

        # Add owfont (open weather) icon set to concerto-frontend layout for weather content shown on screens
        add_view_hook "frontend/ScreensController", :concerto_frontend_plugins do
          "#{ stylesheet_link_tag 'assets/concerto_weather/application.css' }"
        end

      end
    end
  end
end
