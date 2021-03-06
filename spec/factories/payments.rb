FactoryGirl.define do
  factory :disburse do
    amount "999.99"
    type "Disburse"
    date "2015-10-31"
    association :credit_agreement

    before :create do |disburse|
      if disburse.credit_agreement.payments.none?
        create :deposit, credit_agreement: disburse.credit_agreement, amount: 2 * disburse.amount
      end
    end
  end


  factory :deposit do
    amount "999.99"
    type "Deposit"
    date "2015-10-31"
    association :credit_agreement
  end
end
