class OnceTest < Borges::Task

  def go
    inform("ready")

    session.once do
      1.upto(3) do |i|
        inform(i.to_s)
      end
    end

    inform("done")
  end

end

