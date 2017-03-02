# Concerto 2 Weather Plugin
This plugin provides support to add weather content in Concerto 2 using the [OpenWeatherMap API](http://openweathermap.org/).

Custom weather icons are included from [owfont](http://websygen.github.io/owfont/).
Additional weather icons are added from [weathericons](https://erikflowers.github.io/weather-icons/).

Concerto 2 Weather is licensed under the Apache License, Version 2.0.

## Installation 
1. Visit the plugin management page in Concerto, select RubyGems as the source and "concerto_weather" as the gem name.
2. Visit the settings page (admin category on the nav bar) and enter your [OpenWeatherMap API key](http://openweathermap.org/appid) under the "API Keys" tab. 
3. For any issues displaying the custom weather icons, make sure to precompile assets using:

    (for production)
    ``` RAILS_ENV=production rake assets:precompile```
    
    (for development)
    ``` RAILS_ENV=development rake assets:precompile```

## Added support for formatting

A custom formatting script is now supported. It can be added at creation time of the forecast

It uses ruby's variable substitution. The following variables are supported:

* #{format_city} - City name
* #{format_iconid} - Icon ID in OpenWeatherMap API number. Should be used if you want to use a custom font that supports OWM.
* #{format_icon} - the html code to inject the weather icon (<i...> </i>) - uses OWF or WI font based on the setting
* #{format_high} - High temperature (including units) for the day
* #{format_low}  - Low temperature (including units) for the day
* #{format_current} - Current temperature (including units). Updated every 5 minutes by default.


It can be used for example as follows:

```
                <h1>#{format_city}</h1>
                <div style='float: left; width: 50%'>
                   #{format_icon}
                </div>
                <div style='float: left; width: 50%'>
                  <h1> &uarr; #{format_high} | &darr; #{format_low} </h1>
                </div>
```
Variables can be omitted, used twice, etc..

If no format is specified the following is used:

```
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
````

Current Temperature only available if forecast type selected to be "Realtime". 
Conversely, high/low temperatures for the day are available if forecast is "Max and Min for the day"

