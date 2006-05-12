# Note: this file runs fine by itself, but i has several interactions with
# other tests and other files. This makes it unsuitable for running as 
# part of the suite.

require 'timeclock/util/Configuration'
require 'timeclock/util/test-util'
require 'rbconfig'
require 'ftools'

module Timeclock

  class ConfigurationTests < Test::Unit::TestCase

    todo 'There must be a clean recursive delete somewhere.'
    def fully_delete_directory(dir)
      if File.exists?(dir)
        Dir[dir+'/*'].each { | file | File.delete(file) } 
        Dir.delete(dir)
      end
    end

    def setup
      ENV.delete('VW_TIMECLOCK_DATA_DIR')
      fully_delete_directory('./Test-user-dir/logs')
      fully_delete_directory('./Test-user-dir/user-data')
      Dir.delete('./Test-user-dir') if File.exists?('./Test-user-dir')
    end

    def teardown
      setup
    end

    def without_vendor_specific_directory
      target = Config::CONFIG['target_vendor']
      begin
        Config::CONFIG['target_vendor'] = 'none'
        yield
      ensure
        Config::CONFIG['target_vendor'] = target
      end
    end

    def without_home
      home = ENV['HOME']
      begin
        ENV.delete("HOME")
        yield
      ensure
        ENV['HOME'] = home
      end
    end
      

    def test_configuration_data_dir

      # Unset data directory is a fatal error.
      without_vendor_specific_directory {
        assert_exception_with_message(ConfigurationProblem,
                                      Configuration.no_data_dir) {
          Configuration.data_dir
        }        
      }

      # Often set through environment.
      ENV['VW_TIMECLOCK_DATA_DIR'] = '/tmp'
      assert_equal('/tmp', Configuration.data_dir)
    end

    def test_configuration_data_dir_on_apple
      # On OS X, put data in a standard place.
      if Config::CONFIG['target_vendor'] == "apple"

        # That's under your home directory, so
        # it's an error if HOME is not defined.
        without_home {
          assert_exception_with_message(ConfigurationProblem,
                                        Configuration.no_home) {
            Configuration.data_dir
          }
        }
        assert_equal("#{ENV['HOME']}/Library/Timeclock",
                     Configuration.data_dir)
      end
    end

    # Note that we don't handle the case where the 'directory'
    # exists, but is a plain file.
    def test_configuration_ensure_data_dir
      ENV['VW_TIMECLOCK_DATA_DIR'] = './Test-user-dir'
      assert(! File.exists?('./Test-user-dir'))
      Configuration.ensure_data_dir
      assert(File.exists?('./Test-user-dir'))
      assert(File.exists?('./Test-user-dir/user-data'))
      assert(File.exists?('./Test-user-dir/logs'))

      # No problem if it already exists
      Configuration.ensure_data_dir
      assert(File.exists?('./Test-user-dir'))
      assert(File.exists?('./Test-user-dir/user-data'))
      assert(File.exists?('./Test-user-dir/logs'))
    end

    def test_user_file
      ENV['VW_TIMECLOCK_DATA_DIR'] = './Test-user-dir'
      assert_equal("./Test-user-dir/user-data/foo",
                   Configuration.user_file('foo'))
    end

    def test_log_file
      ENV['VW_TIMECLOCK_DATA_DIR'] = './Test-user-dir'
      assert_equal("./Test-user-dir/logs/foo",
                   Configuration.log_file('foo'))
    end

  end
end

