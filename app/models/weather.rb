class Weather < DynamicContent
  DISPLAY_NAME = 'Weather'

  # Weather needs a location.
  def self.form_attributes
    attributes = super()
    attributes.concat([:config => [:zip_code]])
  end
end
