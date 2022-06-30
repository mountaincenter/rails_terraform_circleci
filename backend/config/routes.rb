Rails.application.routes.draw do
  root to:"home#index"
  get  'home/index'
  get  '/health_check', to: 'health_checks#index'
  get  '/blogs',        to: 'blogs#index'
  get  '/blogs/:id',    to: 'blogs#show'
  post '/blogs',        to: 'blogs#create'
end
