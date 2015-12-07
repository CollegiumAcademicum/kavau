class CreditAgreement < ActiveRecord::Base
  strip_attributes

  # TODO: Add notes
  belongs_to :creditor, class_name: 'Address'
  belongs_to :account
  has_many :payments, -> { order 'date asc' }, dependent: :restrict_with_exception
  has_many :balances, -> { order 'date asc' }, dependent: :destroy
  has_many :auto_balances, -> { order 'date asc' }
  has_one :termination_balance

  delegate :belongs_to_project?, to: :account, prefix: true

  validates_presence_of :amount, :interest_rate, :cancellation_period, :account_id, :creditor_id
  validates_numericality_of :amount, greater_than_or_equal_to: 500
  validates_numericality_of :interest_rate, greater_than_or_equal_to: 0, less_than: 100
  validates_numericality_of :cancellation_period, greater_than_or_equal_to: 3
  validate :account_valid_for_credit_agreement?
  validate :termination_date_after_payments

  after_touch :create_missing_balances, :delete_unnecessary_balances, :update_balances
  before_save :make_termination_balance

  def self.funded_credits_sum
    sum(:amount)
  end

  def self.average_rate_of_interest
    return 0 unless funded_credits_sum > 0
    sum('interest_rate * amount') / funded_credits_sum
  end

  def todays_total
    todays_balance.end_amount
  end

  def total_interest
    balances.interest_sum + todays_balance.interests_sum
  end

  def todays_balance
    auto_balances.build
  end

  def active?
    !terminated? && payments.any?
  end

  def terminated?
    return false if errors[:terminated_at].any?
    !terminated_at.blank?
  end

  def reopen!
    unset_terminated_at
    save
  end

  private
    def account_valid_for_credit_agreement?
      return unless account
      return if account_belongs_to_project?
      errors.add(:base, :only_project_accounts_valid)
    end

    def termination_date_after_payments
      return if terminated_at.blank? || payments.none?
      return if terminated_at >= payments.last.date
      errors.add(:terminated_at, :before_last_payment)
    end

    def update_balances
      auto_balances.each(&:update_end_amount!)
    end

    def delete_unnecessary_balances
      balances.younger_than(date_of_first_payment).destroy_all
    end

    def create_missing_balances
      (obligatory_balances_dates - existing_balances_dates).each do |balance_date|
        auto_balances.create(date: balance_date)
      end
    end

    def make_termination_balance
      return unless terminated_at
      create_termination_balance(date: terminated_at)
    end

    def existing_balances_dates
      balances.pluck(:date)
    end

    def obligatory_balances_dates
      (date_of_first_payment.year...this_year).map{ |y| Date.new(y, 12, 31) }
    end

    def date_of_first_payment
      (payments.first || NullPayment.new).date
    end

    def unset_terminated_at
      self.terminated_at = nil
    end

    def this_year
      Date.today.year
    end

  class NullPayment
    def date
      Date.today
    end
  end
end
