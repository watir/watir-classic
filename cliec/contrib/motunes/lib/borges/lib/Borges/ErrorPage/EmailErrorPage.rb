class Borges::EmailErrorPage < Borges::ErrorPage

  def emailAddresses
    return ['root@localhost']
  end

  def emailText
    return String.streamContents do |s|
      self.printWalkbackOn(s)
    end
  end

  def printExceptionDescriptionOn(aResponse)
    aResponse.nextPutAll(exception.description)
    aResponse.cr
  end

  def printFooterForStackFrame_on(aContext, aStream)
    aStream.nextPutAll('--------')
  end

  def printHeaderForStackFrame_on(aContext, aStream)
    aStream.cr
    aStream.nextPutAll(aContext.fullPrintString)
    aStream.cr
  end

  def printObject_labelled_on(anObject, aString, aStream)
    aStream.space
    aStream.space
    aStream.space
    aStream.nextPutAll(aString)
    (20 - aString.size).times do aStream.space end
    aStream.nextPutAll(anObject.printStringLimitedTo(100))
    aStream.cr
  end

  def printStackFrameListEndOn(aStream)
  end

  def printStackFrameListStartOn(aStream)
  end

  def show
    SeasidePlatformSupport.deliverMailFrom_to_text('seaside@beta4.com', self.emailAddresses, self.emailText)
    super.show
  end

end

