# extends CL/IEC

class FormElements
  include Enumerable
  
  def initialize (fe)
    @fe = fe
  end

  def each
    @fe.each {yield}
  end
end
