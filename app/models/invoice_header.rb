class InvoiceHeader < ActiveRecord::Base
  
  has_many :invoice_lines, :order => :position

  # Return the default directory for this site: we are going to test for (first) r:/ror which is GHW, then q:/ror (AIM).
  # This is only used at fire-up time.
  #
  def self.find_default_directory
    result = ''
    %w{ r:/ror q:/ror }.each do |d|
      if File.directory?(d)
        result = d
        break
      end
    end
    return result
  end # of method "find_default_directory".
  
  # return the text for the active state of the toggle.
  #
  def self.fetch_active_state(pathName, toggle = false)
    result = issue = nil
    keyFile = 'ror_yes'
    unless File.directory?(pathName) : issue = "<e>\"#{pathName}\" is not a directory path."
    else
      Dir.chdir(pathName)
      result = File.exist?(keyFile)
      # if we are to toggle it, then do so.
      if toggle
        if result  # remove the file named 'ror_yes'.
          File.delete(keyFile)
        else  # create a nominal file named 'ror_yes'.
          f = File.new(keyFile, 'w')
          f << DateTime.now
          f.close
        end
        result = !result
      end # of whether toggling the active state.
      # restore the original state.
      Dir.chdir(RAILS_ROOT) # don't forget this little gem.
    end
    return issue, result ? 'Turn Printing OFF' : 'Turn Printing ON'
  end # end of method "fetch_active_state".
  
  def self.process_next_raw_file(activeFlag, pathName)
    issue = nil
    headerId = nil
    copies = nil
    if activeFlag.include?('ON') : issue = ''  # remember: inverted.
    elsif pathName.nil? : issue = "<e>No directory path is specified."
    elsif !File.directory?(pathName) : issue = "<e>\"#{pathName}\" is not a directory path."
    else
      Dir.chdir(pathName)
      fileNames = Dir['*.ror']
      if fileNames.empty? : issue = '<w>No invoices pending'
      else
        fileNames.sort!
        targetFileName = fileNames.first
        issue, headerId, copies = load_dataflex_invoice(targetFileName)
        # rename the file so it's not processed again.
        File.rename(targetFileName, targetFileName.gsub('ROR', 'OK')) if issue.nil?
      end
      Dir.chdir(RAILS_ROOT) # don't forget this little gem.
    end # of whether printing is 'off'.
    return issue, headerId, copies
  end # of method "process_next_raw_file".
  

  def self.get_manual_list
    result = self.find(:all, :order => 'invoice DESC', :limit => 25)
    unless result.empty?
      result = result.collect {|ih| [ih.invoice, ih.id]}
    end
    issue = case result.size
    when 0 : "No invoices are available for reprinting."
    when 1 : "Select the last invoice."
    else
      "Select from the last #{result.size} invoice(s)."
    end
    return issue, result
  end
  
  def self.load_dataflex_invoice(fileNamr)
    copies = 'N'
    f = File.new( fileNamr, 'r' ) rescue nil
    if f.nil? : issue = "<e>Could not open source file: #{fileNamr}"
    else
      newRawData = f.readlines
      f.close
      if newRawData.empty? : issue = "Nothing to do!"
      else
        @headerRaw = {}
        @linesRaw = []
        @lineRaw = {}
        currentMode = nil
        newRawData.each do |d|
          d.chomp!  # drop the eol.
          # find out if we are opening/closing a data block.
          if d[0,2].eql?'--'
            # save our stacked-up data if we are working with lines.
            # (note, the final mode of the file will always be 'total'.)
            unless currentMode.nil?
              unless %w{ --header --total }.include?(currentMode)
                @linesRaw << @lineRaw.clone unless @lineRaw.empty?
                @lineRaw.clear
              end
              @lineRaw[:line_mode] = d.gsub('-','')
            end
            # identify our new save mode.
            currentMode = d
          else
            newSet = d.split(': ')
            unless skip_list.include?(newSet[0])
              newPair = Hash[newSet[0].gsub('-','_').to_sym, ((newSet[1].strip rescue nil) || '')]
              if %w{ --header --total }.include?(currentMode) : @headerRaw.merge!(newPair)
              else
                @lineRaw.merge!(newPair)
              end
            end # of skipping unwanted pairs.
          end # of treating a raw line.
        end # of enumerating each raw data line.
        #
        # Let's post the data now -- the header here, then pass the id for the lines to be saved.
        # However, first order of business is to remove any old data.
        # BTW, i originally had the lines as dependent=>destroy, but they didn't go away.
        #
        invoiceHeaderRow = InvoiceHeader.find(:first, :conditions => ["invoice = ?", @headerRaw[:invoice]])
        if invoiceHeaderRow
          InvoiceLine.delete_all("invoice_header_id = '#{invoiceHeaderRow.id}'") rescue nil
          InvoiceHeader.delete_all("invoice = '#{@headerRaw[:invoice]}'") rescue nil
        end # of removing residual old invoice.
        @headerRaw[:workorder].gsub!('_', '')
        headerSaved = InvoiceHeader.create(@headerRaw)
        # the delivery notes and all deposit lines must precede parts, labor, and text.
        %w{ delivery deposit rest}.each do |m|
          @linesRaw.each do |l|
            case m
            when 'delivery' : InvoiceLine.create(l.merge!(:invoice_header_id => headerSaved.id)) if l[:line_mode].eql?(m)
            when 'deposit' : InvoiceLine.create(l.merge!(:invoice_header_id => headerSaved.id)) if l[:line_mode].eql?(m)
            else
              InvoiceLine.create(l.merge!(:invoice_header_id => headerSaved.id)) unless %w{ delivery deposit }.include?(l[:line_mode])
            end
          end # of saving every line item.
        end # of loading each mode.
        issue = nil   # (loaded successfully)
        f.close unless f.closed?
      end # of empty file.
    end #of whether there is any downloaded data at all.
    headerId = headerSaved.nil? ? nil : headerSaved.id
    return issue, headerId, copies
  end # of method "load_dataflex_invoice".

  def self.company_data(formatCode)
    companies = {
      :ghw => {
        :address => "2619 Southwest Second Avenue, Fort Lauderdale, Florida, 33315-3115\nPhone: 954.463.2577, Fax: 954.463.3846\nE-Mail: info@generalhardwoods.com",
        :website => "www.generalhardwoods.com",
        :logo => "ghmi_logo_invoice.gif"
      }
    }
    return companies[formatCode.to_sym]
  end # of method "company_data".
  
  private
  
  def self.skip_list
    %w{ page body-blank } 
  end
    
end # of class "InvoiceHeader".
