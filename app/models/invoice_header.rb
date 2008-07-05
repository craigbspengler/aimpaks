class InvoiceHeader < ActiveRecord::Base
  
  has_many :invoice_lines, :order => :position

  def self.load_dataflex_invoice(fileName)
    rawFileName = fileName.include?(':') ? fileName : File.join('public', 'tmp', fileName)
    f = File.new( rawFileName, 'r' ) rescue nil
    if f.nil? : issue = "<e>Could not open source file: #{rawFileName}"
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
        issue = "<i>Loaded."
        f.close unless f.closed?
      end # of empty file.
    end #of whether there is any downloaded data at all.
    return issue
  end # of method "load_dataflex_invoice".

  def self.company_data(formatCode)
    {
      :address => "2619 Southwest Second Avenue, Fort Lauderdale, Florida, 33315-3115\nPhone: 954.463.2577, Fax: 954.463.3846\nE-Mail: info@generalhardwoods.com",
      :website => "www.generalhardwoods.com",
      :logo => "ghmi_logo_invoice.gif"
    }
  end # of method "company_data".
  
  private
  
  def self.skip_list
    %w{ page body-blank } 
  end
    
end # of class "InvoiceHeader".
