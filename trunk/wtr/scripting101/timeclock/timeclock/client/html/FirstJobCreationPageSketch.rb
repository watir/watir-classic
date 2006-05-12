require 'timeclock/util/ruby-extensions'
require 'timeclock/client/html/PageSketch'
require 'timeclock/client/PrettyTimes'

module Timeclock
  module Client
    module Html

      class FirstJobCreationPageSketch < PageSketch

        attr_reader :session_id # fills in PageSketch#command_form template.

        def initialize(session_id)
          @session_id = session_id
          super "Create the First Job"
        end
        
        def body_guts
          column1 =
            command_form('job',
                         tight_table(head_row(b('Please create the first job')),
                                     tr(td(center(BodyBlueFill),
                                           input({:type => 'text',
                                                   :name => 'name',
										           :id => 'first_job',
                                                   :size => '16',
                                                   :maxlength => '100'}),
					   input({:type => 'submit',
                                                   :name => 'create_first_job',
                                                   :value => 'Create'}),
                                           div(input({:type => 'checkbox',
                                                       :name => 'background',
                                                       :value => 'true',
                                                       :checked => 'true'}),
                                               "Make it a background job")))))
                                           
          column2 = table(tr(td(p(
                      "If you make this job a background job, it will be a
                       job that accumulates time when you're not doing any
                       specific task. You'll start it in the morning, do
                       your work - starting and pausing other jobs -
                       then stop it when you're done for the day."),
                             p(
                      "Each time you pause another job, the background job
                       will resume accumulating time."),
                             p(
                      "If you don't have a background job, you'll have to
                       manage time more explicitly."))))

          [tight_table(tr(td({:width => "40%", :align=>"center"},
                             column1),
                          td(column2)))]
        end
      end
    end
  end
end
