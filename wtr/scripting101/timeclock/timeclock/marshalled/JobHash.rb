require 'timeclock/util/misc'
module Timeclock
  module Marshalled

    class JobHash < Hash

      todo 'can subjobs be background jobs?'
      # Note that the following does not discover them.

      def background_job
        values.find { | job | job.is_background? } 
      end

      def has_parent_of?(job)
        has_key?(job.parent.name)
      end

      def job_has_this_child?(child)
        self[child.parent.name].subjobs.has_key?(child.name)
      end

      def install_child(child)
        self[child.parent.name].subjobs[child.name] = child
      end

      def delete_child(child)
        result = self[child.parent.name].subjobs.delete(child.name)
        assert(child == result)
        result
      end
    end

  end
end
