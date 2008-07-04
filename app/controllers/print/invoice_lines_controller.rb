class Print::InvoiceLinesController < ApplicationController

#  active_scaffold

  def index
    @lines = InvoiceLine.find(:all)
    render :layout => 'index.pdf.rtex'
  end

end
