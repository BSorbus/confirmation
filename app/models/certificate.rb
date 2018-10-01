require 'net/http'

class Certificate
	include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  extend ActiveModel::Translation

	attr_accessor :number_prefix, :number, :date_of_issue, :valid_thru, :name, :given_names, :birth_date

  # validates
  validates :number_prefix, presence: true,
                    length: { in: 3..4 }
  validates :number, presence: true,
                    length: { is: 5 },
                    numericality: { only_integer: true }
  validates :date_of_issue, presence: true,
                    length: { is: 10 }
  validates :valid_thru, presence: true, 
                    length: { is: 10 }, :if => :condition_testing?
  validates :name, presence: true,
                    length: { in: 1..100 }
  validates :given_names, presence: true,
                    length: { in: 1..100 }
  validates :birth_date, presence: true,
                    length: { is: 10 }

  # callbacks 
  before_validation :prepare_data_params

  def condition_testing?
      !(valid_thru.blank? && ['GL-', 'GS-', 'MA-', 'GS-', 'GC-', 'IW-'].include?(number_prefix))
  end

  def prepare_data_params
    self.number_prefix = Loofah.fragment("#{self.number_prefix}").text
    self.number = Loofah.fragment("#{self.number.strip}").text
    self.date_of_issue = Loofah.fragment("#{self.date_of_issue}").text
    self.valid_thru = Loofah.fragment("#{self.valid_thru}").text
    self.name = Loofah.fragment("#{self.name.strip}").text
    self.given_names = Loofah.fragment("#{self.given_names.strip}").text
    self.birth_date = Loofah.fragment("#{self.birth_date}").text
  end

  def request_certificate(token, remote_ip)
    begin
      # uri = URI("http://localhost:3000/api/v1/certificates/mor_search_by_multi_params")
      uri = URI("#{Rails.application.secrets[:netpar2015_api_url]}/certificates/mor_search_by_multi_params")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
      req = Net::HTTP::Get.new(uri.path, {'Content-Type' => 'application/json', 'Authorization' => "#{token}", 'X-Real-IP' => "#{remote_ip}"})
      req.body = {"number_prefix" => "#{self.number_prefix}", "number" => "#{self.number}", "date_of_issue" => "#{self.date_of_issue}", "valid_thru" => "#{self.valid_thru}", "name" => "#{self.name}", "given_names" => "#{self.given_names}", "birth_date" => "#{self.birth_date}" }.to_json
      res = http.request(req)
      JSON.parse(res.body)
    rescue => e
      puts '========================== API ERROR "certificate" =========================='
      puts "#{e}"
      puts '============================================================================='
    end
  end  

end
