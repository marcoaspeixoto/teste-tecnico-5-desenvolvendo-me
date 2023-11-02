Rails.application.routes.draw do
  resources :talks do
    collection do
      post 'import_from_txt'
    end
  end
end
