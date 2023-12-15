Rails.application.routes.draw do
  root 'talks#home'
  post '/import', to: 'talks#import'
  get '/talks', to: 'talks#index'
  get '/schedule', to: 'talks#schedule'
end
