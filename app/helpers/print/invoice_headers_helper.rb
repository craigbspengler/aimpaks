module Print::InvoiceHeadersHelper
  include AimFormsHelper
  
  def file_name_options
    result = options_for_select(session[:fileNamesList])
    return result.nil? ? [''] : result
  end

  def delivery_phone
    delivery_area_code = @bodyRow.delivery_area_code rescue nil || ''
    delivery_exchange = @bodyRow.delivery_exchange rescue nil || ''
    delivery_number = @bodyRow.delivery_number rescue nil || ''
    "#{delivery_area_code}.#{delivery_exchange}.#{delivery_number}"
  end
  
  def delivery_special
    result = @bodyRow.delivery_special0 rescue nil || ''
    result << @bodyRow.delivery_special1 rescue nil || ''
  end

end # of module "InvoiceHeadersHelper".
