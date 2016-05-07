function buildResultsTable(data) {
  console.log(data);
  // Build a table to display city query results
  // User can select a city that best matches their intended location
  table = "<table class='table table-condensed'> \
           <thead><tr><th>Name</th><th>Country</th><th>Lat</th><th>Lng</th>";
  tableBody = "<tbody>";

  var places = data.list;
  for (var i = 0; i < places.length; i++) {
    var lat = places[i].coord.lat;
    var lng = places[i].coord.lon;
    var row = "<tr class='link-hl' data-lat='"+lat+"' data-lng='"+lng+"'> \
              <td>" + places[i].name + "</td> \
              <td>" + places[i].sys.country + "</td> \
              <td>" + lat + "</td> \
              <td>" + lng + "</td>";
    tableBody += row;
  }

  tableBody += "</tbody></table>";
  tableBody += "<hr/><i>Can't find your city? Try entering your zip code <b>or</b> your city along with its state (ex: Madison, WI).</i>"
  return table + tableBody;
}

function initCityIdSearch() {
  var query_el = $('input#weather_config_city_query')
  query_el.on('focusout', searchForCityInfo);

  function searchForCityInfo() {
    var info_el = $('.city-info');
    var cityQuery = $('input#weather_config_city_id').val();

    if (info_el.length != 0) {
      // Add a 'searching' placeholder while city query results are loading
      $(info_el).empty().html('<i class=\"fa fa-spinner fa-spin\"></i> searching...');
      // Query the OpenWeatherAPI to find a list of matching cities based on input
      $.ajax({
        url: "/concerto_weather/city_search.js",
        data: {"q": query_el.val()},
        dataType: 'json',
        timeout: 4000,
        success: function(data) {
          // Build a table of results returned from city query
          var resultsTable = buildResultsTable(data);
          // Show city results from query
          $(info_el).empty().html(resultsTable);
          // Handle click events on city results
          $(info_el).find('tr').on('click', function(e) {
            $('#weather_config_lat').val($(e.currentTarget).data("lat"));
            $('#weather_config_lng').val($(e.currentTarget).data("lng"));
            $(info_el).empty();
          });
        },
        error: function()  {
          $(info_el).empty().html("<p>No results found.</p>");
        }
      });
    }
  }
}

$(document).ready(initCityIdSearch);
