class Weather < DynamicContent
  DISPLAY_NAME = 'Weather'

  UNITS = {
    'c' => 'Celsius',
    'f' => 'Fahrenheight'
  }

  validate :woeid_must_exist

  def build_content
    require 'rss'
    require 'net/http'

    url = "http://weather.yahooapis.com/forecastrss?w=#{self.config['woeid']}&u=#{self.config['units']}"

    feed = Net::HTTP.get_response(URI.parse(url)).body

    rss = RSS::Parser.parse(feed, false, true)

    weather_data = rss.items.first
    sanitized_data = weather_data.description
    htmltext = HtmlText.new()
    htmltext.name = weather_data.title
    rawhtml = "<h1>#{rss.channel.title}</h1><i>#{weather_data.title}</i><p>#{sanitized_data}</p>"
    Rails.logger.debug rawhtml
    htmltext.data = ActionController::Base.helpers.sanitize(rawhtml, :tags => ['i', 'img', 'b', 'br', 'p', 'h1'])
    return [htmltext]
  end

  # Weather needs a location.  Also allow specification of units
  def self.form_attributes
    attributes = super()
    attributes.concat([:config => [:woeid, :units]])
  end

  def woeid_must_exist
    if self.config['woeid'].empty?
      errors.add(:woeid, 'must be specified')
    end

# http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20geo.places%20where%20woeid%20%3D%202972&diagnostics=true
# cbfunc({
#  "query": {
#   "count": 1,
#   "created": "2013-04-24T01:36:06Z",
#   "lang": "en-US",
#   "diagnostics": {
#    "publiclyCallable": "true",
#    "url": {
#     "execution-start-time": "1",
#     "execution-stop-time": "24",
#     "execution-time": "23",
#     "content": "http://where.yahooapis.com/v1/place/2972;start=0;count=10"
#    },
#    "user-time": "25",
#    "service-time": "23",
#    "build-version": "36288"
#   },
#   "results": {
#    "place": {
#     "lang": "en-US",
#     "xmlns": "http://where.yahooapis.com/v1/schema.rng",
#     "yahoo": "http://www.yahooapis.com/v1/base.rng",
#     "uri": "http://where.yahooapis.com/v1/place/2972",
#     "woeid": "2972",
#     "placeTypeName": {
#      "code": "7",
#      "content": "Town"
#     },
#     "name": "Winnipeg",
#     "country": {
#      "code": "CA",
#      "type": "Country",
#      "woeid": "23424775",
#      "content": "Canada"
#     },
#     "admin1": {
#      "code": "CA-MB",
#      "type": "Province",
#      "woeid": "2344917",
#      "content": "Manitoba"
#     },
#     "admin2": {
#      "code": "",
#      "type": "County",
#      "woeid": "29375231",
#      "content": "Manitoba"
#     },
#     "admin3": null,
#     "locality1": {
#      "type": "Town",
#      "woeid": "2972",
#      "content": "Winnipeg"
#     },
#     "locality2": null,
#     "postal": null,
#     "centroid": {
#      "latitude": "49.853748",
#      "longitude": "-97.152298"
#     },
#     "boundingBox": {
#      "southWest": {
#       "latitude": "49.713631",
#       "longitude": "-97.349121"
#      },
#      "northEast": {
#       "latitude": "49.993870",
#       "longitude": "-96.955482"
#      }
#     },
#     "areaRank": "6",
#     "popRank": "12"
#    }
#   }
#  }
# });
 
 
# THE REST QU




      #   video_id = URI.escape(self.config['video_id'])
      #   url = "http://vimeo.com/api/v2/video/#{video_id}.json"
      #   uri = URI.parse(url)
      #   http = Net::HTTP.new(uri.host, uri.port)
      #   request = Net::HTTP::Get.new(uri.request_uri)
      #   response = http.request(request)
      #   if response.code == '200'  #ok
      #     json = response.body
      #     data = ActiveSupport::JSON.decode(json)
      #   end
      # #rescue
      # #  Rails.logger.debug("YouTube not reachable @ #{url}.")
      # #  config['video_id'] = ''
      # #  return
      # #end
      # if data.empty?
      #   Rails.logger.debug('No video found from ' + url)
      #   self.config['video_id'] = ''
      #   return
      # end
  end
end
