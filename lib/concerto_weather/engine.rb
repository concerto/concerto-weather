module ConcertoWeather
  class Engine < ::Rails::Engine
    isolate_namespace ConcertoWeather

    initializer "register content type" do |app|
      app.config.content_types << Weather
    end
  end
end
