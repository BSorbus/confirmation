class CertificatesController < ApplicationController

  caches_page :new, :eclaration, :gzip => :best_speed

  def declaration 
  end

  def new

    # exam_obj = NetparExam.new(token: user_netpar_token, id: "#{params[:id]}")
    # response_obj = exam_obj.request_with_id
    # render json: response_obj.body, status: response_obj.code 


    @certificate ||= Certificate.new
    @certificate.number_prefix = params[:number_prefix] if params[:number_prefix].present?
    @certificate.number = params[:number] if params[:number].present?
    @certificate.date_of_issue = params[:date_of_issue] if params[:date_of_issue].present?
    @certificate.valid_thru = params[:valid_thru] if params[:valid_thru].present?
    @certificate.name = params[:name] if params[:name].present?
    @certificate.given_names = params[:given_names] if params[:given_names].present?
    @certificate.birth_date = params[:birth_date] if params[:birth_date].present?
  end

  # POST /certificates
  # POST /certificates.json
  def create
    @certificate = Certificate.new(certificate_params) #merge parmas with token, remote_ip
    if @certificate.valid?
      @certificate_resp = @certificate.request_certificate
      respond_to do |format|
        format.html { render :new }
      end
    else
      respond_to do |format|
        format.html { render :new }
      end
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
    # Never trust parameters from the scary internet, only allow the white list through.
    def certificate_params
      params.require(:certificate).permit(:number_prefix, :number, :date_of_issue, :valid_thru, :name, :given_names, :birth_date).merge(token: user_netpar_token, remote_ip: request.remote_ip)
    end

end
