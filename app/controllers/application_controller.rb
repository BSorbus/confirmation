class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_locale

  def default_url_options
    { locale: I18n.locale }
  end

  helper_method :user_netpar_token

  def user_netpar_token
    if session[:user_netpar_token_last_used].blank? || (Time.zone.now - session[:user_netpar_token_last_used] > 590.seconds)
      session[:user_netpar_token_last_used] = Time.zone.now
      session[:user_netpar_token] = NetparUser.new.request_for_token
    else
      session[:user_netpar_token_last_used] = Time.zone.now
      session[:user_netpar_token] 
    end
  end

  private
  
    def set_locale
      I18n.locale = params[:locale] || I18n.default_locale
    end
    
end
