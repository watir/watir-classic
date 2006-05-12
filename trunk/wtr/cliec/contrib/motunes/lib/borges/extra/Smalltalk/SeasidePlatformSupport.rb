class SeasidePlatformSupport

  def self.deliverMailFrom_to_text(fromAddress, recipientList, messageText)
    SMTPSocket.deliverMailFrom_to_text_usingServer(
      fromAddress,
      recipientList,
      messageText,
      self.smtpServer)
  end

  def self.mimeDocumentClass
    return MIMEDocument 
  end

  def self.profileSendsDuring(aBlock)
    Processor.activeProcess.priority: 20
    Smalltalk.garbageCollectMost
    return String.streamContents do |stream| 
      mt = (MessageTally.new)
      mt.spyEvery(1)
      mt.on do
        aBlock.value
        Smalltalk.garbageCollectMost
      end
      mt.report(stream)
    end
  end

  def self.smtpServer
    return 'localhost'
  end

  def self.vmStatisticsReportString
    return Utilities.vmStatisticsReportString 
  end

  def self.weakDictionaryOfSize(aNumber)
    dict = WeakIdentityKeyDictionary.new(aNumber)
    WeakArray.addWeakDependent(dict)
    return dict
  end

end

