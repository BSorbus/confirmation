require 'net/http'

class User
	include ActiveModel::Model

	attr_accessor :email, :password, :token

  def initialize()
    @email    = "#{Rails.application.secrets[:netpar2015_api_user]}"
    @password = "#{Rails.application.secrets[:netpar2015_api_user_pass]}"
  end


  def request_login 
    begin
      # uri = URI("http://localhost:3000/api/v1/login")
      uri = URI("#{Rails.application.secrets[:netpar2015_api_url]}/login")
      http = Net::HTTP.new(uri.host, uri.port)
      #http.use_ssl = true
      #http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
      req = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
      req.body = {"email" => "#{self.email}", "password" => "#{self.password}"}.to_json
      res = http.request(req)
      JSON.parse(res.body)
    rescue => e
      puts '============================= API ERROR "login" ============================='
      puts "#{e}"
      puts '============================================================================='
    end
  end  

end
