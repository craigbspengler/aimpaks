module AimFormsHelper
  
  def should_edit?
    ['new', 'edit'].include?(params[:action])
  end
  
  def formatted_value(model_instance, attribute)
    value = model_instance.send(attribute.to_s)
    value.is_a?(BigDecimal) ? sprintf("%0.2f", value) : value.to_s
  end
  
  def money(source, dollar_sign = false)
    value = source || BigDecimal.new(0.00)
    result = number_to_currency(value)
    return dollar_sign ?  result : result.gsub('$', '')
#    result = sprintf("%0.2f", value)
#    return dollar_sign ? ("$#{result}") : result
  end

  # Build up an html component according to the first {string|symbol} which
  # MUST contain five characters, case and positionally significant,
  # defined as (dot=do-nothing place-holder):
  #   0) r = add <tr><td>; d = add <td>; u = add <ul><li>; o = add <ol><li>; l = add <li>
  #   1) l = label; s = left-side label; o = overhead label
  #   2) v = add <div>; s = add <span>
  #   3) a = anchor, c = checkbox; f = textfield; r = radio; s = select; t = textarea
  #                                            if r, labelText becomes 'value'.
  #      Case: if uppercase, add multi-model convention (model[]).                                      
  #   4) d = </td>; r = </td></tr>; u = </li></ul>; o = </li></ol>; l = </li>
  #   
  #   FURTHER, this first parm can be wrapped as the first element in an array
  #   where the second element is a hash with keys of the above and values which
  #   are ascii strings to include in the related html tag.  In the case of an
  #   anchor (at 3) it is the full html to insert as the anchor element.
  #   
  # parm2:
  #   model instance
  # parm3:
  #   attribute name
  # parm4:
  #   label (value or nil for derived)
  # parm5:
  #   html attribute hash
  # parm6:
  #   (optional) options list for select, radiobuttons.
  #
  def aim_build(structure, model, attribute, label=nil, html_attributes={}, options={})
    s, more = structure_parse(structure)
    # if this is a hash (e.g. :blank attribute) an upcase means class rt id tag.
    cssSelector = 'id'
    if s[3][0] > 96 : s3model, cssSelector = model, 'id'
    elsif model.is_a?(Hash) : s3model, cssSelector = model, 'class'
    else
      s3model, cssSelector = "#{model.to_s}[]", 'class'
    end
    s[3].downcase!
    labelText = case label
    when nil : attribute.to_s.titleize
    when ':' : "#{attribute.to_s.titleize}:&nbsp;&nbsp;"
    else
      label
    end
    r = ''
    # start constructing.
    # (0) ----------------------------------------
    r << case s[0]
    when 'r': "<tr#{more.fetch(:r,'')}><td#{more.fetch(:d,'')}>"
    when 'd': "<td#{more.fetch(:d,'')}>"
    when 'u': "<ul#{more.fetch(:u,'')}><li#{more.fetch(:l,'')}>"
    when 'o': "<ol#{more.fetch(:o,'')}><li#{more.fetch(:l,'')}>"
    when 'l': "<li#{more.fetch(:l,'')}>"
    else
      ''
    end # of (0)
    r << '<div>'
    # (1) ----------------------------------------
    r << case s[1]
    when 'l': "<label#{more.fetch(:l,'')}>#{labelText}</label>"
    when 's': "<span#{more.fetch(:l,'')} class=\"form-font\">#{labelText}</span>"
    when 'o': "<label#{more.fetch(:l,'')}>#{labelText}</label>"
    else
      ''
    end
    # (flatten the double td's for the side label)
    r.gsub!('<td><td', '<td')
    # (2) ----------------------------------------
    # let's add an id for this field to assist in printing reports w/css.
    attributeCleansed = attribute.to_s.gsub('.', '_')
    idName = if should_edit? : ''
    elsif model.is_a?(Hash) : "#{cssSelector}=\"hash_#{attributeCleansed}\""
    else
      "#{cssSelector}=\"#{model.to_s}_#{attributeCleansed}\""
    end
    r << case s[2]
    when 'v': "<div#{more.fetch(:v,'')} #{idName}>"
    when 's': "<span#{more.fetch(:s,'')} #{idName} class=\"data-font\">"
    else
      ''
    end # of (2).
    # (3) ----------------------------------------
    unless should_edit?
      attributeValue = if model.is_a?(Hash) : model.fetch(attribute,'')
      else
        attributes = attribute.to_s.split('.')
        case attributes.size
        when 3: eval("@#{model}").send(attributes[0]).send(attributes[1]).send(attributes[2]) rescue nil || ''
        when 2: eval("@#{model}").send(attributes[0]).send(attributes[1]) rescue nil || ''
        else
          eval("@#{model}").send(attributes[0]) rescue nil || ''
        end
      end # of setting the attribute's value.
      body = case s[3]
      when 'c': evaluate_checkbox(attributeValue)
      when 'f': evaluate_text_field(attributeValue, options)
      when 'r': attributeValue
      when 's': evaluate_select(attributeValue, options)
      when 't': evaluate_textarea(attributeValue, s[0])
      else
        ''
      end # of body format-variable mode.
      # add in the formatted attributeValue.
      body = '&nbsp;' if body.nil? || body.to_s.empty?
      unless body.is_a?(BigDecimal) : r << body.to_s
      else
        r << sprintf("%0.2f", body)
        r.sub!('data-font', 'data-font right')
      end # of treating a big decimal result and backstuffing the right-justify.
    else
      r<< case s[3]
      when 'c': (check_box( s3model, attribute, html_attributes.merge({:tabindex => tab_index()})) rescue nil) || '&nbsp;'
      when 'f': (text_field( s3model, attribute, html_attributes.merge({:tabindex => tab_index()})) rescue nil) || '&nbsp;'
      when 'r': (radio_button( s3model, attribute, labelText, html_attributes.merge({:tabindex => tab_index()})) rescue nil) || '&nbsp;'
      when 's': (select( s3model, attribute, options, {},html_attributes.merge({:size => "1", :tabindex => tab_index()})) rescue nil) || '&nbsp;'
      when 't': (text_area( s3model, attribute, html_attributes.merge({:tabindex => tab_index()})) rescue nil) || '&nbsp;'
      else
        ''
      end # of edit-body mode.
    end # of (3).
    # (close 2) ----------------------------------
    r << case s[2]
    when 'v': "</div>"
    when 's': "</span>"
    else
      ''
    end # of (close 2).
    # (4) ----------------------------------------
    r << '</div>'
    r << case s[4]
    when 'r': '</td></tr>'
    when 'd': '</td>'
    when 'u': '</li></ul>'
    when 'o': '</li></ol>'
    when 'l': '</li>'
    else
      ''
    end # of (4).
    # (5) ----------------------------------------
    # we are done.
    return r
  end # of method "build".
  
  def text_field_with_label(model, attribute, label=nil, html_attributes={}, label_is_detail=false)
    wrap_with_label_and_div( (label || attribute.to_s.titleize), 
      eval("@#{model}").send(attribute.to_s),
      text_field( model, attribute, html_attributes.merge(field_options())))
  end
  
  def auto_complete_text_field_with_label(model, attribute, label=nil, html_attributes={}, auto_complete_options={})
    wrap_with_label_and_div( (label || attribute.to_s.titleize), 
      eval("@#{model}").send(attribute.to_s),
      text_field_with_auto_complete( model, attribute, html_attributes.merge({:tabindex => tab_index()}), auto_complete_options))
  end
  
  def auto_complete_text_field_side_label(model, attribute, label=nil, html_attributes={}, auto_complete_options={})
    wrap_label_and_body_with_table_row( (label || attribute.to_s.titleize), 
      eval("@#{model}").send(attribute.to_s),
      text_field_with_auto_complete( model, attribute, html_attributes.merge({:tabindex => tab_index()}), auto_complete_options))
  end

  def text_area_with_label(model, attribute, label=nil, html_attributes={})
    wrap_with_label_and_div( (label || attribute.to_s.titleize), 
      eval("@#{model}").send(attribute.to_s),
      text_area( model, attribute, html_attributes.merge({:tabindex => tab_index()})))
  end

  def checkbox_with_label(model, attribute, label=nil, html_attributes={})
    wrap_with_label_and_div( (label || attribute.to_s.titleize), 
      eval("@#{model}").send(attribute.to_s),
      check_box( model, attribute, 
        html_attributes.merge({:tabindex => tab_index()})))
  end

  def select_with_label(model, attribute, label=nil, html_attributes={})
    wrap_with_label_and_div( (label || attribute.to_s.titleize), 
      eval("@#{model}").send(attribute.to_s),
      select( model, attribute, 
        eval("@#{attribute.to_s.pluralize}").collect {|p| [capitalize_abbreviations(truncate(p.port_name.titleize)), p.port_name]},
        html_attributes.merge({:tabindex => tab_index()})))
  end

  def select_with_label_and_options(model, attribute, options, label=nil, html_attributes={})
    wrap_with_label_and_div( (label || attribute.to_s.titleize), 
      eval("@#{model}").send(attribute.to_s),
      select( model, attribute, options, {},
        html_attributes.merge({:size => "1", :tabindex => tab_index()})))
  end

  def select_side_label_and_options(model, attribute, options, label=nil, html_attributes={})
    wrap_side_label_and_div( (label || attribute.to_s.titleize), 
      eval("@#{model}").send(attribute.to_s),
      select( model, attribute, options, {},
        html_attributes.merge({:size => "1", :tabindex => tab_index()})))
  end

  def text_field_row_with_side_label(model, attribute, label=nil, html_attributes={})
    wrap_label_and_body_with_table_row( (label || attribute.to_s.titleize),
      eval("@#{model}").send(attribute.to_s),
      text_field( model, attribute, html_attributes.merge({:tabindex => tab_index()})))
  end

  def text_field_with_side_label(model, attribute, label=nil, html_attributes={})
    wrap_side_label_and_body( (label || attribute.to_s.titleize),
      eval("@#{model}").send(attribute.to_s),
      text_field( model, attribute, html_attributes.merge({:tabindex => tab_index()})))
  end

  # Generate (print-level) html for a label followed by div construction surrounding the value.
  # If first parm is nil, second is value to render, otw assume model name w/attribute symbol as second.
  # Finally, third is label if non-nil otw use titleized second-parm-symbol; third parm required if
  # first parm is nil.
  def label_plus_div(model, attribute, label=nil, html_options={})
    ourValue = model ? eval("@#{model}").send(attribute.to_s) : attribute
    wrap_with_label_and_div((label || attribute.to_s.titleize), ourValue, html_options)
  end
  
  def js_finish_auto_complete(options=nil)
    "function(element, item) {tab_to_next_field(this); new Ajax.Request('#{url_for({:action => 'finish_auto_complete'}.merge(options))}', {asynchronous:true, evalScripts:true, parameters:'value=' + element.value})}"
  end
  
  def capitalize_abbreviations(s)
    exceptions = ['St', 'Ct', 'Dr', 'Rd']
    s.gsub(/([A-Z][a-z])($|,|\s)/) { |match| exceptions.include?(match) ? match : match.upcase }
  end
  
  # this adds a method to any helper module which includes this module
  def self.included(base)
    base.module_eval do
      
      # this method adds <column>_column helper methods for improving the
      # display properties of the data in active_scaffold
      # see Main::ShipmentsHelper for example usage
      def self.add_column_helper_methods(*columns)
        column_helper_method_names = columns.collect {|c| (c.to_s + '_column')}
        column_helper_method_names.each do |column_helper_method|
          method_name = column_helper_method.gsub('_column', '')
          unless self.respond_to?(column_helper_method)
            case
            when column_helper_method.match(/address|port/)
              self.module_eval <<-EOM
                def #{column_helper_method}(record)
                  record.#{method_name} ? capitalize_abbreviations( record.#{method_name}.titleize).gsub("\n", '<br />') : '-'
                end
              EOM
            when column_helper_method.match(/phone/)
              self.module_eval <<-EOM
                def #{column_helper_method}(record)
                  record.#{method_name} ? number_to_phone( record.#{method_name}.gsub(/\D/, '') ) : '-'
                end
              EOM
            else
              # The assign, below, used to have ".titlize" but that's presumptuous [CBS].
              self.module_eval <<-EOM
                def #{column_helper_method}(record)
                  record.#{method_name} ? record.#{method_name} : '-' 
                end
              EOM
            end
          end
        end
      end
      
    end # module_eval
  end 

  # Return a <br/>-delimited string from the billing/shipping address four-lines in a DataFLEX construct.
  # The arguments are the data-class and either 'bill' or 'ship' with columns of 'name', add1-3'.
  #
  def collapse_address(dataClass, blockName)
    list = %w{name add1 add2 add3}.collect {|c| (dataClass.send("#{blockName}_#{c}").strip rescue nil) || ''}
    return list.join('<br/>').gsub('<br/><br/>', '<br/>')
  end # of method "collapse_address".
  
  private
  
  def field_options
    #    {:tabindex => tab_index(), :style => 'background-color: #fff;'}
    {:tabindex => tab_index()}
  end
  
  def tab_index
    @tabindex = @tabindex ? @tabindex+1 : 1
  end

  def structure_parse(structure)
    more = {}
    if structure.class.to_s.eql?("Array")
      s = structure[0].to_s.split(//)
      structure[1].each {|k, v| more.merge!(k => " #{v.strip}")} unless structure[1].nil?
    else
      s = structure.to_s.split(//)
    end # of array or simple argument.
    return s, more
  end # of method "structure_parse".

  # Returns a printable value for the attribute from a checkbox list.
  #
  def evaluate_checkbox(attributeValue)
    (attributeValue.nil? || attributeValue == 0) ? 'NO' : 'YES'
  end # of method "evaluate_checkbox".

  # Returns s formatted date or datetime if such, otw value of the argument.
  # 
  def evaluate_text_field(attributeValue, options)
    if attributeValue.is_a?(Date)
      formatter = (options[:date] rescue nil) || DateShort
      attributeValue.strftime(formatter)
    elsif attributeValue.is_a?(DateTime)
      formatter = (options[:datetime] rescue nil) || DateTimeShort
      attributeValue.strftime(formatter)
    else
      attributeValue
    end
  end # of method "evaluate_text_field".
  
  # Returns a printable value for the attribute from a select Options list.
  #
  def evaluate_select(attributeValue, options)
    if options.nil? || attributeValue.nil? : ''
    elsif options[0].is_a?(Array) : options.rassoc(attributeValue)[0]
    else
      attributeValue
    end
  end # of method "evaluate_select".  
  
  # Returns a blockquote, with appropriate html <br/>'s replacing newlines.
  # OTOH, if we are doing a list mode, just install the interior tags.
  #
  def evaluate_textarea(attributeValue, structure)
    textArea = attributeValue || ''
    if 'rdq'.include?(structure)
      "<blockquote><p>#{textArea.gsub("\n",'<br/>')}</p></blockquote>"
    elsif 'uol'.include?(structure)
      "#{textArea.chomp.gsub("\n",'</li><li>')}"
    else
      "#{textArea.gsub("\n",'<br/>')}"
    end # of list or block mode.
  end # of method "evaluate_textarea".
  
  def wrap_side_label_and_div(label_text, body, edit_body=nil, label_is_detail=false)
    s = "<td class=\"right\"><label>#{label_text}</label></td><td class=\"right\" style=\"border: 0px;\">"
    s << "<div>"
    s << ((edit_body && should_edit?) ? edit_body : body)
    return s + "</div></td>"
  end
  
  def wrap_with_label_and_div(label_text, body, edit_body=nil, label_is_detail=false)
    s = "<label#{label_is_detail ? ' class="lading-form-label-detail"' : ''}>#{label_text}</label>"
    s << ((edit_body && should_edit?) ? "<div>#{edit_body}</div>" : "<div>#{body}</div>")
    return s
  end
    
  def wrap_label_and_body_with_table_row(label_text, body, edit_body=nil)
    s = "<tr><td class=\"right\"><label style=\"margin-right: 0;\">#{label_text}</label></td><td class=\"right\" style=\"border: 0px;\">"
    body = body.is_a?(BigDecimal) ? sprintf("%0.2f", body) : body.to_s
    s << ((edit_body && should_edit?) ? edit_body : body)
    return s + "</td></tr>"
  end
    
  def wrap_side_label_and_body(label_text, body, edit_body=nil)
    s = "<td class=\"right\"><label style=\"margin-right: 0;\">#{label_text}</label></td><td class=\"right\" style=\"border: 0px;\">"
    body = body.is_a?(BigDecimal) ? sprintf("%0.2f", body) : body.to_s
    s << ((edit_body && should_edit?) ? edit_body : body)
    return s + "</td>"
  end

end