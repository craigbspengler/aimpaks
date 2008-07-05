class Print::InvoiceHeadersController < ApplicationController
  
  #  active_scaffold

  def index
    @headers = InvoiceHeader.find(:all)
  end # of action "index".
  
  def load_invoice
    issue = InvoiceHeader.load_dataflex_invoice(params[:fileNamr])
    set_flash issue
    redirect_to :action => 'index'
  end # of action "load_invoice".

  # Print out the invoice from the dataFLEX print intermediate file.
  #
  def print_invoice
    @headerRow = InvoiceHeader.find(:first)
    
    unless @headerRow
      set_flash('<e>No invoice found to print.')
      redirect_to :action => 'index'
    else
      @reportInfo = {
        :action => :print_invoice,
        :title => 'Invoice',
        :fileTag => @headerRow.invoice.to_s,
        :currentUser => {:id => '1'},
        :layout => params[:medium],
        :cssFile => "ghw_invoice",
#        :cssFile => "#{@headerRow[:format_code].downcase.strip}_invoice"
        :company => InvoiceHeader.company_data(@headerRow.format_code)
        }
      render_html_or_redirect_to_pdf
    end
  end # of action "print_invoice".

end # of class "InvoiceHeadersController".
