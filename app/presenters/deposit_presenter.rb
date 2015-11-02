class DepositPresenter < PaymentPresenter
  def amount
    h.number_to_currency(@model.amount)
  end
end