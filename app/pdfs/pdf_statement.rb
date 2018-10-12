class PdfStatement < Prawn::Document

  # { "category"=>"M", 
  #   "customer"=>{ "birth_date"=>"1953-11-27", 
  #                 "given_names"=>"Krzysztof", 
  #                 "id"=>"74975", "name"=>"Ziętara"}, 
  #   "date_of_issue"=>"2018-07-13", 
  #   "division"=>{ "english_name"=>"VHF radiotelephone operator's certificate", 
  #                 "id"=>"15", 
  #                 "name"=>"świadectwo operatora radiotelefonisty VHF", 
  #                 "number_prefix"=>"MA-", 
  #                 "short_name"=>"VHF"}, 
  #   "id"=>"81115", 
  #   "number"=>"MA-05998", 
  #   "valid_thru"=>""}



  # info:
  # Author – who created the document
  # CreationDate – the date and time when the document was originally created
  # Creator – the originating application or library
  # Producer – the product that created the PDF. In the early days of PDF people would use a Creator application like Microsoft Word to write a document, print it to a PostScript file and then the Producer would be Acrobat Distiller, the application that converted the PostScript file to a PDF. Nowadays Creator and Producer are often the same or one field is left blank.
  # Subject – what is the document about
  # Title –  the title of the document
  # Keywords – keywords can be comma separated
  # ModDate -the latest modification date and time  

  def initialize(certificate_data, view, author, title)
    super(:page_size => "A4", 
          :page_layout => :portrait,
          :info => {
                      :Title        => title,
                      :Author       => author,
                      :Subject      => "",
                      :CreationDate => Time.now,
                    }
          )

    @view = view

    font_families.update("DejaVu Sans" => {
      :normal => "#{Rails.root}/app/assets/fonts/DejaVuSans.ttf", 
      :bold  => "#{Rails.root}/app/assets/fonts/DejaVuSans-Bold.ttf",
      :italic => "#{Rails.root}/app/assets/fonts/DejaVuSans-Oblique.ttf",
      :bold_italic => "#{Rails.root}/app/assets/fonts/DejaVuSans-BoldOblique.ttf"
    })
    font "DejaVu Sans", size: 11

    logo
#    header_left_corner
    header_right_corner
    qrcode(certificate_data)
    data(certificate_data)
    footer
  end


  def logo
    image "#{Rails.root}/app/assets/images/logo_uke_en_do_lewej.png", :at => [0, 780], :height => 25
    stroke_line [0,735], [525,735], self.line_width = 0.1
  end

  def qrcode(cert)
    qrcode_content = "#{Rails.application.secrets[:search_url]}" +
                      "?number_prefix=#{cert[:division][:number_prefix]}&number=#{cert[:number].last(5)}&date_of_issue=#{cert[:date_of_issue]}&valid_thru=#{cert[:valid_thru]}" +
                      "&name=#{cert[:customer][:name]}&given_names=#{cert[:customer][:given_names]}&birth_date=#{cert[:customer][:birth_date]}"
    print_qr_code(qrcode_content, pos: [390, 140], extent: 144, stroke: false, level: :m)

    # text_box "#{qrcode_content}", size: 10, 
    #   :at => [0, 615], 
    #   :width => 500, 
    #   :height => 100
  end

  def header_left_corner
    draw_text "Faktura VAT nr:", :at => [0, 690], size: 11
    draw_text "#{@invoice_customer.id}/#{@invoice_date.month}/-#{@invoice_customer.agent_number}-/#{@invoice_date.year}", :at => [0, 675], size: 12

    draw_text "Nabywca:", :at => [0, 630], size: 12, :style => :bold
    text_box "#{@invoice_customer_address_with_nip}", size: 12, 
      :at => [0, 615], 
      :width => 265, 
      :height => 100
  end

  def header_right_corner
    draw_text "Gdynia, " + Time.now.strftime('%Y-%m-%d'), :at => [400, 710], size: 11
  end


  def data(cert)
    #move_down 80
    #current_row = 525

    valid_thru = cert[:valid_thru].present? ? "#{cert[:valid_thru]}" : "---------- (without expiry date)"

    draw_text "Confirmation #{cert[:division][:short_name]}", :at => [0, 610], size: 14

    draw_text "Office of Electronic Communications informs that the certificate:", :at => [0, 560], size: 11

    draw_text "Type:", :at => [70, 520], size: 11
          draw_text "#{cert[:division][:english_name]} (#{cert[:division][:short_name]})", :at => [150, 520], size: 11
    draw_text "No.:", :at => [70, 500], size: 11
          draw_text "#{cert[:number]}", :at => [150, 500], size: 11
    draw_text "Date of issue:", :at => [70, 480], size: 11
          draw_text "#{cert[:date_of_issue]}", :at => [150, 480], size: 11
    draw_text "Valid thru:", :at => [70, 460], size: 11
          draw_text "#{valid_thru}", :at => [150, 460], size: 11

    draw_text "has been issued for #{cert[:customer][:name]} #{cert[:customer][:given_names]} (date of birth #{cert[:customer][:birth_date]}).", :at => [0, 420], size: 11

    text_box "The above certificate has been issued according to the IMO Convention STCW by the " + 
             "President of the Office of Electronic Communications.", size: 11, :align => :justify, 
      :at => [0, 380], 
      :width => 525, 
      :height => 300

  end

  def footer
    stroke_color "BECC25"
    stroke_line [0, 10], [525,10], self.line_width = 2.0
    text "generated from https://confirmation.uke.gov.pl,  e-mail: ske.gdynia@uke.gov.pl,  © 2018 UKE", size: 6, :style => :italic, :align => :right, :valign => :bottom  
  end

end
