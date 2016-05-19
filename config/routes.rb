Rails.application.routes.draw do
  resources :weathers, :controller => :contents, :except => [:index, :show], :path => 'content'
end

ConcertoWeather::Engine.routes.draw do
  get '/city_search', to: 'search#find_city'
end
