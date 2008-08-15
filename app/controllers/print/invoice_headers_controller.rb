class Print::InvoiceHeadersController < ApplicationController
  
  #  active_scaffold

  #-------------------------------------------------------------------------------------------------------------
  # Automatic (polled) operation: js loops every (10) seconds to see if any new *.ror file is present.
  # Use effects to show that the poll took place.
  #-------------------------------------------------------------------------------------------------------------

  def index
    session[:directory] = session[:directory] || InvoiceHeader.find_default_directory
    issue, session[:active] = InvoiceHeader.fetch_active_state(session[:directory])
    set_flash issue
  end # of action "index".

  def auto_submit
    if params[:commit].eql?('Set New Path')
      session[:directory] = params[:pathName]
      redirect_to :action => 'index' and return
    elsif params[:commit].include?('Turn Printing')
      issue, session[:active] = InvoiceHeader.fetch_active_state(session[:directory], true)
      redirect_to :action => 'index' and return
    else
      redirect_to :action => 'manual_control'
    end
  end
  
  def poll_for_data
    issue, headerId, copies = InvoiceHeader.process_next_raw_file(session[:active], session[:directory])
    if issue.nil?
      redirect_to(:action => 'print_invoice', :invoice_id => headerId, :medium => 'pdf_invoice', :invoiceCopies => copies) and return
    else
      # report that we cycled with the scripaculous effect.
      set_flash issue
      render :update do |page|
        page.replace_html 'flash-messages', :partial => 'flash_messages'
        page.visual_effect :highlight, 'whole-page'  # , :startcolor => "'#ffff99'", :endcolor => "'#bbbbbb'", :restorecolor => "'#bbbbbb'"
        page.assign 'pcrActive', true
      end # of reporting cycle.
    end # of whether found/printed or not.
  end # of action "check_instructions".

  #-------------------------------------------------------------------------------------------------------------
  # Manual reprint: for any invoice already transferred, the last ten are displayed to give opportunity to
  # either reprint or choose addition packing list, etc.
  #-------------------------------------------------------------------------------------------------------------
  def manual_control
    issue, @invoices = InvoiceHeader.get_manual_list
    set_flash issue
  end

  def manual_submit
    if params[:commit].eql?('Refresh')
      session[:fileNamesList] = ''
      redirect_to :action => 'manual_control' and return
    elsif params[:commit].eql?('Automatic Operation')
      redirect_to :action => 'index' and return
    else
      redirect_to :action => 'print_invoice', :invoice_id => params[:invoice_id], :invoiceCopies => params[:invoiceCopies]
    end
  end
  
  #  def load_invoice
  #    issue = InvoiceHeader.load_dataflex_invoice(params[:fileNamr])
  #    set_flash issue
  #    redirect_to :action => 'manual_control'
  #  end # of action "load_invoice".

  #-------------------------------------------------------------------------------------------------------------
  # This section holds action(s) used by both the automatic and manual operating modes.
  #-------------------------------------------------------------------------------------------------------------
  
  # Print out the invoice from the MySQL-extant data.
  #
  def print_invoice
    @headerRow = InvoiceHeader.find(params[:invoice_id])
    @bodyRows = @headerRow.invoice_lines(:order => 'position')
    unless @headerRow
      set_flash('<e>No invoice found to print.')
      redirect_to(:action => 'manual_control') and return
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
        :layout => 'pdf_invoice',
        :cssFile => 'ghw_invoice',
        #        :cssFile => "#{@headerRow[:format_code].downcase.strip}_invoice"
        :company => InvoiceHeader.company_data(@headerRow.format_code)
      }
      render_html_or_redirect_to_pdf
    end
  end # of action "print_invoice".

end # of class "InvoiceHeadersController".
