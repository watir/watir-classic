require 'remote-web-services'
require 'test/unit'

class TestStart < Test::Unit::TestCase
	def test_start
		session = start_session_for('fred')
		job = Job.named('job')
		session.accept_job(job)
		session.start('job', Time.now)
		assert_equal(true, session.running?('job'))
	end
end	