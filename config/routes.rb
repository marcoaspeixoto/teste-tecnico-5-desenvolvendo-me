Rails.application.routes.draw do
  resources :talks do
    collection do
      get 'index'
      post 'import_from_txt'
    end
  end

  post 'talks/import', to: 'talks#import' # Esta rota para importação não precisa estar aninhada
end
