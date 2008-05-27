require 'watir' 

#we start the logger by calling these Class (static) methods
class LoggerFactory 
  
  def LoggerFactory.start_default_logger(fileNamePrefix)
    time = Time.now.strftime("%m %d %Y %H %M %s")  
    logger = CoreLogger.new(File.join(File.dirname(__FILE__), "#{fileNamePrefix}_#{time}.txt") ,2, 1000000)
    return logger 
  end 
  
  def LoggerFactory.start_xml_logger(fileNamePrefix) 
    time = Time.now.strftime("%m %d %Y %H %M %s") 
    logger = XMLLogger.new(File.join(File.dirname(__FILE__), "#{fileNamePrefix}_#{time}.txt") ,2, 1000000, "#{fileNamePrefix}_#{time}.XML")
    return logger 
  end 
  
end 


#this logs anything that Watir.rb tries to log, and everything with a "log" method to a text
#file that can be used for debugging.
class  CoreLogger < Watir::WatirLogger 
  
  def initialize(fileName, logsToKeep, maxLogSize) 
    super(fileName , logsToKeep, maxLogSize) 
    self.level = Logger::INFO 
    self.datetime_format = "%d-%b-%Y %H:%M:%S" 
    self.info("Core Logger starting...")          
  end 
  
  #overloaded "log" from logger.rb to something more intuitive.
  def log(message) 
    puts "log #{message}\n"  #optional. comment out if you don't want to see logging in the console
    info(message)                   #calls info in logger.rb -- would be good to use different logging levels
  end 
end 


#use object inheritance to fire up the corelogger to log everything to
#create a new XML file we can log to as well
class XMLLogger < CoreLogger 
  def initialize(fileName, logsToKeep, maxLogSize, xmlFileName ) 
    #start the core logger 
    super(fileName ,logsToKeep, maxLogSize) 
    self.level = Logger::INFO 
    self.datetime_format = "%d-%b-%Y %H:%M:%S" 
    
    #start an XML logger 
    log "Starting XMLLogger..."  #log calls the parent method "log" in CoreLogger class
    @logfile = File.new(xmlFileName, "w") 
    @logfile.puts "<?xml version='1.0'?>" 
    @logfile.puts "<results>" 
    
  end 
  
  #hackish method to log results without aid of REXML or other Ruby XML tools
  def log_results(name, input, expected, test_status) 
    log("XML file output: Test case: " + name + " input: " + input + " expected: " + expected + " status: " + test_status) 
    @logfile.puts'<result testcase="' + name + '" input= "' + input + '" expected="' + expected + '">' 
    @logfile.puts test_status
    @logfile.puts"</result>" 
  end 
  
  #hack to close the tag and the file
  def end_log
    @logfile.puts"</results>"
    @logfile.close
  end
  
end
