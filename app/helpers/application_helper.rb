# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def messages
    result = []
    for name in [:error, :warning, :info]
      if flash[name]
        if result.empty?
          result = '<div id="messages">'
          result << link_to( 'Clear', :redirect_to => :back )
        end
        result << "<span class=\"#{name.to_s}-message\">&nbsp;#{flash[name]}&nbsp;<span><br/>"
      end
    end
    result << "</div>" unless result.empty?
    return result
  end
  
end # of module "ApplicationHelper".
