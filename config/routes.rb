Rails.application.routes.draw do
  resources :weathers, :controller => :contents, :except => [:index, :show], :path => "content"
end
