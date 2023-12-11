Rails.application.routes.draw do
  root 'talks#home'
  post '/import', to: 'talks#import'
  get '/talks', to: 'talks#index'
end
