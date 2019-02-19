Rails.application.routes.draw do
  resources :home, :article
  get :article_list, controller: :home
  root 'home#index'
end
