var ConcertoWeather = {
  _initialized: false,

  weatherRowClickHandler: function (event) {
    // Handle click events on city results
    // Lat/lng saved with weather content for future API calls.
    $("#weather_config_lat").val($(this).attr("data-lat"));
    $("#weather_config_lng").val($(this).attr("data-lng"));
    // Reset all selected rows
    $(".city-info").find("tr").each(function() {
      $(this).attr("data-selected", "0");
      $(this).removeClass("alert-info");
    });
    // Set a new selected row
    $(this).attr("data-selected", "1");
    $(this).addClass("alert-info");
  },

  reverseGeocode: function (place) {
    // Reverse gecode returned coordinates from OpenWeatherMap API
    // OpenWeatherMap API returns limited location information so this is important
    //   if users want to distinguish similarly named places
    var params = {
      format: "json",
      lat: place.coord.lat,
      lon: place.coord.lon
    };

    $.ajax({
      url: "https://nominatim.openstreetmap.org/reverse",
      data: params,
      dataType: "json",
      success: function(data) {
        // Add a row to our results table
        var lat = place.coord.lat;
        var lng = place.coord.lon;
        var row = "<tr class='link-hl' data-selected='0' data-lat='"+lat+"' data-lng='"+lng+"'> \
                  <td>" + place.name + "</td> \
                  <td>" + (data.address.county || '') + "</td> \
                  <td>" + (data.address.state || '') + "</td> \
                  <td>" + (data.address.country_code.toUpperCase() || '') + "</td>";
        $('#cityResults tr:last').after(row);
        // Handle click events for search results
        $('#cityResults tr:last').on('click', ConcertoWeather.weatherRowClickHandler)
      }
    });
  },

  buildResultsTable: function (data) {
    var places = data.list;
    var info_el = $(".city-info");
    // Build a table to display city query results
    // User can select a city that best matches their intended location
    table = "<table id='cityResults' class='table table-condensed'> \
             <thead><th>Name</th><th>District/County/Region</th><th>Province/State</th><th>Country</th>";
    tableBody = "<tbody></tbody></table>";
    tableBody += "<hr/><i>You must select your city from the list above.  Can't find your city? Try entering your zip code <b>or</b> your city along with its state (ex: Madison, WI).</i>"
    // Insert our empty results table
    $(info_el).empty().html(table + tableBody);
    // Find the address info for each weather search result
    // Then insert the place data into our results table
    if (typeof places != 'undefined') {
      for (var i = 0; i < places.length; i++) {
        ConcertoWeather.reverseGeocode(places[i]);
      }
    }
  },

  searchForCityInfo: function () {
    var info_el = $(".city-info");
    var cityQuery = $("input#weather_config_city_query").val();

    if (info_el.length != 0 && cityQuery.length > 0) {
      // clear out any prior selected city
      $("#weather_config_lat").val("");
      $("#weather_config_lng").val("");

      // Add a 'searching' placeholder while city query results are loading
      $(info_el).empty().html("<i class='fa fa-spinner fa-spin'></i> searching...");
      // Query the OpenWeatherAPI to find a list of matching cities based on input
      $.ajax({
        url: "/concerto_weather/city_search.js",
        data: {"q": cityQuery},
        dataType: "json",
        timeout: 6000,
        success: function(data) {
          // Build a table of results returned from city query
          ConcertoWeather.buildResultsTable(data);
        },
        error: function(data)  {
          $(info_el).empty().html("<p>No results found.</p>");
        }
      });
    }
  },

  initHandlers: function () {
    if (!ConcertoWeather._initialized) {
      var query_el = $("input#weather_config_city_query")
      query_el.on("focusout", ConcertoWeather.searchForCityInfo);
      ConcertoWeather._initialized = true;
    }
  }
}

$(document).ready(ConcertoWeather.initHandlers);
$(document).on('turbolinks:load', ConcertoWeather.initHandlers);
