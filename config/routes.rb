Rails.application.routes.draw do

  scope "(:locale)", locale: /en|pl/ do
  	get '/certificates', to: 'certificates#new'
  	get '/certificates/new', to: 'certificates#new'
  	post '/certificates', to: 'certificates#create'
    get '/certificates/statement_to_pdf'
  	get '/certificates/declaration', to: 'certificates#declaration'

    root to: 'certificates#new'
  end

end
