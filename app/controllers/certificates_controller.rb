class CertificatesController < ApplicationController

  def new
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
    @certificate = Certificate.new(certificate_params)
    if @certificate.valid?
      @user = User.new
      user_resp = @user.request_login 
      token = user_resp["user"]["authentication_token"] if user_resp.present? && user_resp["user"].present? 
      @certificate_resp = @certificate.request_certificate(token, request.remote_ip)
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
      params.require(:certificate).permit(:number_prefix, :number, :date_of_issue, :valid_thru, :name, :given_names, :birth_date)
    end

end
