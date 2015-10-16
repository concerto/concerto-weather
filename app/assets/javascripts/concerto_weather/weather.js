
// attach handler to woeid so when it loses focus we can look it up
// not dry, but no middle man
function attachWoeidHandlers() {
  console.log('attaching woeid handlers');

  $('input#weather_config_woeid').on('keyup', getWoeidInfo);

  function getWoeidInfo() {
    // will place name, district-county, province-state, country, woeid into 'div.woeid-info'

    var info = '<p>WOEID details could not be determined.</p>';
    var woeid = $('input#weather_config_woeid').val();
    var info_el = $('.woeid-info');
    var woeidName = $('i.woeid-name');

    // something was changed, so wipe out the pre-existing woeid name
    if (woeidName.length != 0) {
      $(woeidName).text('');
    }

    if (info_el.length != 0) {
      // we found the summary box
      $(info_el).empty().html('<i class=\"fa fa-spinner fa-spin\"></i> searching...');
      $.ajax({
        url: "//query.yahooapis.com/v1/public/yql?q=" + encodeURIComponent("select woeid, placeTypeName, name, admin1, admin2, country from geo.places where (text = \"" +  woeid + "\" or woeid = \"" + woeid + "\") limit 5") + "&format=json",
        dataType: 'jsonp',
        timeout: 4000,
        success: function (data) {

          function htmlEncode(value){
            //create a in-memory div, set it's inner text(which jQuery automatically encodes)
            //then grab the encoded contents back out.  The div never exists on the page.
            return $('<div/>').text(value).html();
          }

          if (data.query && data.query.count > 0 && typeof(data.query.results.place) != "undefined") {
            j = data.query.results.place;
            if (!(j instanceof Array)) {
              j = [ data.query.results.place ];
            }

            // we got something, should use jq datatables with js array load
            // places = []
            // j.forEach(function(item) {
            //   places.push([item.name, item.placeTypeName.content, (item.admin1 ? item.admin1.content : ''),
            //     (item.admin2 ? item.admin2.content : ''), item.country.content, item.woeid]);
            // });

            // icky html table construction (with classes for bootstrap)
            places = "<table class=\"table table-condensed\">";
            places += "<thead><tr><th>Name</th><th>Type</th><th>Province/State</th><th>District/County/Region</th><th>Country</th><th>WOEID</th></th></thead>";
            places += "<tbody>";
            tbody = "";
            j.forEach(function(item) {
              // todo: need htmlencoding
              tbody += "<tr class=\"link-hl\" data-woeid=\"" + item.woeid + "\"><td>" + htmlEncode(item.name) + "</td><td>" +
                htmlEncode(item.placeTypeName.content) + "</td><td>" +
                htmlEncode((item.admin1 ? item.admin1.content : '')) + "</td><td>" +
                htmlEncode((item.admin2 ? item.admin2.content : '')) + "</td><td>" +
                htmlEncode((item.country ? item.country.content : '')) + "</td><td>" +
                item.woeid + "</td></tr>";
            });
            places += tbody + "</tbody></table>";
            info = places;
          }
          $(info_el).empty().html(info);
          // wire up the clicks on the rows to populate the woeid and name fields
          $(info_el).find('tr').on('click', function (e) {
            $('input#weather_config_woeid').val($(this).data('woeid'));
            var name = "";
            $(this).find('td').slice(2,5).each(function () {
              text = $(this).text().trim();
              if (text != "") {
                name += (name != "" ? ", " : "") + text;
              }
            });
            $('input#weather_name').val(name);
          });
        },
        error: function (xoptions, textStatus)  {
          $(info_el).empty().html(info);
        }
      });
    }
  }
}

$(document).ready(attachWoeidHandlers);
$(document).on('page:change', attachWoeidHandlers);
