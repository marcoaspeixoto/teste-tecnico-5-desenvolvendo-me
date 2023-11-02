Rails.application.routes.draw do
  resources :talks do
    collection do
      post 'import_from_txt'
      get 'organize_conference', to: 'conference#organize'
    end
  end
end
