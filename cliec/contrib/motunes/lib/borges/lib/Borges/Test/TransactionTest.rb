class TransactionTest < Borges::Task

  def go
    inform('Before parent txn')

    session.isolate do
      inform('Inside parent txn')

      session.isolate do
        inform('Inside child txn')
      end

      inform('Outside child txn')
    end

    inform('Outside parent txn')
  end

end

