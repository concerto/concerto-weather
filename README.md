# Concerto 2 Weather Plugin
This plugin provides support to add weather content in Concerto 2 using the [OpenWeatherMap API](http://openweathermap.org/).

Custom weather icons are included from [owfont](http://websygen.github.io/owfont/).

Concerto 2 Weather is licensed under the Apache License, Version 2.0.

## Installation 
1. Visit the plugin management page in Concerto, select RubyGems as the source and "concerto_weather" as the gem name.
2. Visit the settings page (admin category on the nav bar) and enter your [OpenWeatherMap API key](http://openweathermap.org/appid) under the "API Keys" tab. 
3. For any issues displaying the custom weather icons, make sure to precompile assets using:

    (for production)
    ``` RAILS_ENV=production rake assets:precompile```
    
    (for development)
    ``` RAILS_ENV=development rake assets:precompile```
