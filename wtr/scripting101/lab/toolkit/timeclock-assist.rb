### Timeclock Specific

def get_status_message
  "Return the status message. Examples are:
No job is recording time, or Job 'ruby article' is running."
  text = $iec.document.getElementsByTagName("P").item(3).innerHtml
  text[/^[^\.]*\./]
end

def start_with_new_user( user )
  
  # Start with a user that has no time records. 
  ensure_no_user_data( user )

  # Go to the application home page
  start_ie( 'http://localhost:8080' )

  # Login with the user
  forms[0].name = user
  forms[0].submit
  $iec.wait

  # Create a background job
  def new_job 
    form{|f| f.action == 'job'}
  end
  new_job.name = 'background'
  new_job.submit
  $iec.wait
end
