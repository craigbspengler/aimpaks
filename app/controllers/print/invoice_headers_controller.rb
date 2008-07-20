class Print::InvoiceHeadersController < ApplicationController
  
  #  active_scaffold

  def index
    session[:fileNamesList] = session[:fileNamesList] || ''
  end # of action "index".

  def refresh
    session[:fileNamesList] = ''
    redirect_to :action => 'index'
  end
  
  def check_instructions
    if params[:fileName].nil? || params[:fileName].empty?
      issue, fileNamesList = InvoiceHeader.check_instructions(params[:pathName])
      set_flash(issue)
      session[:fileNamesList] = fileNamesList if fileNamesList
      redirect_to :action => :index
    else
      fileNamr = File.join(params[:pathName], params[:fileName])
      issue, headerRow = InvoiceHeader.load_dataflex_invoice(fileNamr)
      if headerRow
        redirect_to :action => 'print_invoice', :id => headerRow, :medium => 'pdf_invoice', :invoiceCopies => params[:invoiceCopies]
      else
        set_flash(issue)
        redirect_to :action => :index
      end
    end
  end # of action "check_instructions".
  
  def load_invoice
    issue = InvoiceHeader.load_dataflex_invoice(params[:fileNamr])
    set_flash issue
    redirect_to :action => 'index'
  end # of action "load_invoice".

  # Print out the invoice from the dataFLEX print intermediate file.
  #
  def print_invoice
    @headerRow = InvoiceHeader.find(params[:id])
    @bodyRows = @headerRow.invoice_lines(:order => 'position')
    unless @headerRow
      set_flash('<e>No invoice found to print.')
      redirect_to :action => 'index'
    else
      @copiesInfo = case (params[:invoiceCopies] rescue nil) || 'R'
      when 'N' : [["Account File", :alpha],["Numerical File", :numerical],["Customer's Copy", :customer]]
      when 'D' : [["Account File", :alpha],["Numerical File", :numerical],["Customer's Copy", :customer],["Delivery Note", :packing]]
      when 'R' : [["Reprint", :customer]]
      when 'P' : [["Delivery Note", :packing]]
      end
      @reportInfo = {
        :action => :print_invoice,
        :title => 'Invoice',
        :fileTag => @headerRow.invoice.to_s,
        :currentUser => {:id => '1'},
        :layout => params[:medium],
        :cssFile => 'ghw_invoice',
        #        :cssFile => "#{@headerRow[:format_code].downcase.strip}_invoice"
        :company => InvoiceHeader.company_data(@headerRow.format_code)
      }
      render_html_or_redirect_to_pdf
    end
  end # of action "print_invoice".

end # of class "InvoiceHeadersController".
