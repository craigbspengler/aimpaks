# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def flash_messages
    result = []
    for name in [:error, :warning, :info]
      if flash[name]
        if result.empty? : result = '<div id="messages">'
        else
          result << '<br/>'
        end # of initializing or appending to the message.
        result << "<span class=\"#{name.to_s}-message\">&nbsp;#{flash[name]}&nbsp;<span>"
      end # of evaluating this flash entry.
    end # of enumerating all flash messages.
    unless result.empty?
      result << '<span>&nbsp;&nbsp;&nbsp;'
      result << link_to( 'Clear', :redirect_to => :back )
      result << '</span>'
      result << "</div>"
    end # of closing off the message.
    return result
  end # of method "messages".
  
end # of module "ApplicationHelper".
