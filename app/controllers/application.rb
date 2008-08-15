# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  #  protect_from_forgery :secret => '2a6e91e657dce806429e84ecb4bf4a13', :digest => 'MD5'
  # or
  self.allow_forgery_protection = false  
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  # Set message(s) into flash.  The supplied argument could be an array with more than one message.
  # If it is a string, individual messages can be delimited by semicolons.
  # Each message may be prefixed by a <?> where ? = i/w/e and encodes to the colors used by a-s.
  # If no such encoding, then assume it is an error unless the first word is "Nothing" which means warning.
  #
  def set_flash(message)
    worstResult = nil
    if message && !message.empty?
      mList = message.is_a?(Array) ? message : message.split(';')
      mList.each do |m|
        if m
          ms=m.strip
          # find out the message level and remove any tag.
          messageCode = ms.length < 3 ? '<e>' : ms[0,3]
          messageLevel = %w{<i> <w> <e>}.index(messageCode)
          if messageLevel.nil?
            messageLevel = ms.include?('Nothing') ? 1 : 2
          else
            ms.sub!(messageCode, '')
          end
          # now set the message into the flash.
          flash[%w{info warning error}[messageLevel].to_sym] = ms
        end # of individual valid message test.
      end # of enumerating all messages.
    end # of whether nil argument.
    return worstResult
  end # of method "set_flash".

  def render_html_or_redirect_to_pdf
    if @reportInfo[:layout].include?('pdf_')
      pdf_file = create_pdf
      redirect_to pdf_file.gsub('public', '')
    else
      render :action => @reportInfo[:action]
    end
  end

  def create_pdf
    # make the thing look good, strip off the GUI layout.
    html = render_to_string(:action => @reportInfo[:action], :layout => @reportInfo[:layout])
    #    .gsub(/(src=")(\/images\/.*)\?\d+/, '\1./public\2')
    #   html.match(/<img.*src="(.*)"/)
    #   img_file = File.join($1.split('/'))
    # come up with a good filename (user tag means we can do maintenance on the folder).
    unless @reportInfo[:fileTag]
      uniqueFileName = "xxyy#{rand()}"
    else
      uniqueFileName = "User_#{@reportInfo[:currentUser][:id]}"
      uniqueFileName << "_#{@reportInfo[:title].titleize}"
      uniqueFileName << "_#{@reportInfo[:fileTag].gsub('/','_')}"
    end
    uniqueFileName << ".html"
    # verify the working tmp folder is present: STOP deployment screw-ups!
    Dir.chdir(RAILS_ROOT)
    publicTmpPath = File.join('public','tmp')
    Dir.mkdir(publicTmpPath) unless File.directory?(publicTmpPath)
    fqUniqueFileNamr = File.join(publicTmpPath, uniqueFileName)
    # do the conversion.
    File.open(fqUniqueFileNamr,'w') {|f| f.write html }
    #    htmldoc_cmd = "htmldoc -t pdf14 --charset iso-8859-1 --color --quiet --jpeg --fontsize 14 --no-title --header ... --hfimage0 #{img_file} --webpage public/tmp/#{uniqueFileName}.html > public/tmp/#{uniqueFileName}.pdf"
    #    logger.info htmldoc_cmd
    #    `#{htmldoc_cmd}`
    #    return "public/tmp/#{uniqueFileName}.pdf"
    return fqUniqueFileNamr
  end

end # of class "ApplicationController".
