require 'rails_helper'

RSpec.describe BalancePolicy do
  subject { BalancePolicy.new(user, balance) }
  let(:balance) { FactoryGirl.create(:balance) }

  it_behaves_like "balance_policy"
end

