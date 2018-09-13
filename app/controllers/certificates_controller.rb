require 'net/http'

class CertificatesController < ApplicationController
  def show
  end

  def search
    user = request_login 
    token = user["user"]["authentication_token"] if user.present? && user["user"].present? 
    @request_data = request_certificate(token, params[:number_prefix], params[:number].strip, params[:date_of_issue], params[:valid_thru], params[:name].strip, params[:given_names].strip, params[:birth_date])
    respond_to do |format|
      format.js   { render status: :ok, layout: false, file: 'certificates/result.js.erb' }
    end
  end

  def statement_to_pdf
    documentname = "#{params[:req_data_certificate][:number]}.pdf"
    author = "UKE"

    respond_to do |format|
      format.pdf do
        pdf = PdfStatement.new(params[:req_data_certificate], view_context, author, documentname)
        send_data pdf.render,
        filename: documentname,
        type: "application/pdf",
        disposition: "inline"   
      end
    end
  end



  private

  def request_login 
    begin
      # uri = URI("http://localhost:3000/api/v1/login")
      uri = URI("#{Rails.application.secrets[:netpar2015_api_url]}/login")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
      req = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
      req.body = {"email" => "#{Rails.application.secrets[:netpar2015_api_user]}", "password" => "#{Rails.application.secrets[:netpar2015_api_user_pass]}"}.to_json
      res = http.request(req)
      JSON.parse(res.body)
    rescue => e
      puts '============================= API ERROR "login" ============================='
      puts "#{e}"
      puts '============================================================================='
    end
  end  

  def request_certificate(token, number_prefix, number, date_of_issue, valid_thru, name, given_names, birth_date)
    begin
      # uri = URI("http://localhost:3000/api/v1/certificates/mor_search_by_multi_params")
      uri = URI("#{Rails.application.secrets[:netpar2015_api_url]}/certificates/mor_search_by_multi_params")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
      req = Net::HTTP::Get.new(uri.path, {'Content-Type' => 'application/json', 'Authorization' => "#{token}", 'X-Real-IP' => "#{request.remote_ip}"})
      req.body = {"number_prefix" => "#{number_prefix}", "number" => "#{number}", "date_of_issue" => "#{date_of_issue}", "valid_thru" => "#{valid_thru}", "name" => "#{name}", "given_names" => "#{given_names}", "birth_date" => "#{birth_date}" }.to_json
      res = http.request(req)
      JSON.parse(res.body)
    rescue => e
      puts '========================== API ERROR "certificate" =========================='
      puts "#{e}"
      puts '============================================================================='
    end
  end  

end
