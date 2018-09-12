Rails.application.routes.draw do
  get 'certificates/show'
  post 'certificates/search'
  get 'certificates/statement_to_pdf'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
