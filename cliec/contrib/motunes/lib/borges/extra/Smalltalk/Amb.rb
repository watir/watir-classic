class Amb

  def allValues(aBlock)
    kPrev = @failureContinuation
    results = OrderedCollection.new

    val = Continuation.currentDo do |kRetry|
      @failureContinuation = proc do |v|
        kRetry.value(false)
      end
      results.add(aBlock.value)
      kRetry.value(true)
    end

    self.fail if val

    @failureContinuation = kPrev
    return results.asArray   
  end

  def assert(aBoolean)
    self.fail unless aBoolean
  end

  def deny(aBoolean)
    self.assert((not aBoolean))
  end

  def fail
    return @failureContinuation.value(nil)
  end

  def initialize
    @failureContinuation = proc do
      self.error('Amb tree exhausted')
    end
  end

  def maybe
    return self.oneOf([true, false])
  end

  def oneOf(aCollection)
    return self.valueOfOneOf(aCollection.collect do |ea|
      p = proc do
        ea
      end
      p.fixTemps
    end)
  end

  def valueOf_or(blockOne, blockTwo)
    return self.valueOfOneOf([blockOne, blockTwo])
  end

  def valueOf_or_or(blockOne, blockTwo, blockThree)
    return self.valueOfOneOf([blockOne, blockTwo, blockThree])
  end

  def valueOfOneOf(blockCollection)
    kPrev = @failureContinuation

    return Continuation.currentDo do |kEntry|
      blockCollection.each do |ea|
        Continuation.currentDo do |kNext|
          @failureContinuation = proc do |v|
            @failureContinuation = kPrev
            kNext.value(v)
          end

          @failureContinuation.fixTemps
          kEntry.value(ea.value)
        end
      end

      kPrev.value(nil)
    end
  end

end

