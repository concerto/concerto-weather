function buildResultsTable(data) {
  // Build a table to display city query results
  // User can select a city that best matches their intended location
  table = "<table class='table table-condensed'> \
           <thead><th>Name</th><th>Country</th><th>Lat</th><th>Lng</th>";
  tableBody = "<tbody>";

  var places = data.list;
  for (var i = 0; i < places.length; i++) {
    var lat = places[i].coord.lat;
    var lng = places[i].coord.lon;
    var row = "<tr class='link-hl' data-selected='0' data-lat='"+lat+"' data-lng='"+lng+"'> \
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
  var query_el = $("input#weather_config_city_query")
  query_el.on("focusout", searchForCityInfo);

  function searchForCityInfo() {
    var info_el = $(".city-info");
    var cityQuery = $("input#weather_config_city_query").val();

    if (info_el.length != 0 && cityQuery.length > 0) {
      // Add a 'searching' placeholder while city query results are loading
      $(info_el).empty().html("<i class='fa fa-spinner fa-spin'></i> searching...");
      // Query the OpenWeatherAPI to find a list of matching cities based on input
      $.ajax({
        url: "/concerto_weather/city_search.js",
        data: {"q": cityQuery},
        dataType: "json",
        timeout: 4000,
        success: function(data) {
          // Build a table of results returned from city query
          var resultsTable = buildResultsTable(data);
          // Show city results from query
          $(info_el).empty().html(resultsTable);
          // Handle click events on city results
          $(info_el).find("tr").on("click", function(e) {
            // Lat/lng saved with weather content for future API calls.
            $("#weather_config_lat").val($(this).attr("data-lat"));
            $("#weather_config_lng").val($(this).attr("data-lng"));
            // Reset all selected rows
            $(info_el).find("tr").each(function() {
              $(this).attr("data-selected", "0");
              $(this).removeClass("alert-info");
            });
            // Set a new selected row
            $(this).attr("data-selected", "1");
            $(this).addClass("alert-info");
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
