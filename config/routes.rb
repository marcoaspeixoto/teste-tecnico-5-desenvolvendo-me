Rails.application.routes.draw do
  resources :talks do
    collection do
      post 'import_from_txt'
    end
  end

  post 'talks/import', to: 'talks#import' # Esta rota para importação não precisa estar aninhada
  get 'organize_conference', to: 'conference#organize' # Certifique-se de que a rota de organização da conferência esteja correta
end

