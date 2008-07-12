module Print::InvoiceHeadersHelper
  include AimFormsHelper
  
  def file_name_options
    result = options_for_select(session[:fileNamesList])
    return result.nil? ? [''] : result
  end
  
end
