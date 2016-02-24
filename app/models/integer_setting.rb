class IntegerSetting < Setting
  validates_numericality_of :value, only_integer: true, greater_than_or_equal_to: 0

  def value
    self[:value].to_i
  end

  def form_field_partial
    return super if unit.blank?
    'settings/string_with_unit_field'
  end
end
