class InvoiceLine < ActiveRecord::Base

  belongs_to :invoice_header
  acts_as_list :scope => :invoice_header_id
  
end # of class "InvoiceLine".
