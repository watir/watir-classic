class UploadTest < Borges::Component

  def initialize
    @file = nil
  end

  def render_content_on(r)
    r.heading('Upload File')
    
    r.attributes['enctype'] = 'multipart/form-data'
    r.form do
      r.file_upload do |f| @file = f end
      r.submit_button do end
    end
  
    unless @file.nil? then
      r.bold do r.text(@file.filename) end
      r.preformatted(@file)
    end
  end

end

