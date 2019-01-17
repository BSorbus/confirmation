Rails.application.routes.draw do

	get '/certificates', to: 'certificates#new'
	get '/certificates/new', to: 'certificates#new'
	post '/certificates', to: 'certificates#create'
  get '/certificates/statement_to_pdf'

  root 'certificates#new'

end
