class Setting < ActiveRecord::Base
  after_save :update_config

  def self.update_config
    Setting.all.pluck(:category).each{ |category| update_category(category) }
  end

  def form_field
    :string
  end

  def value=(val)
    self[:value] = (val.blank? ? default : val)
  end

  def to_hash
    {category.to_sym => group_hash}
  end

  def destroy
    self.value = nil
    save
  end

  def form_field_partial
    'settings/string_setting_field'
  end

  def to_partial_path
    'settings/setting'
  end
  
  def help
    I18n.t ['settings', 'help', category, group].compact.map(&:downcase).join('.')
  end

  private
  def self.to_hash
    all.inject({}){ |hash, setting| hash.deep_merge!(setting.to_hash) }
  end

  def name_value_hash
    {name.to_sym => value}
  end

  def sub_group_hash
    return name_value_hash if sub_group.blank?
    {sub_group.to_sym => name_value_hash}
  end

  def group_hash
    return sub_group_hash if group.blank?
    {group.to_sym => sub_group_hash}
  end

  def update_config
    Setting.update_category(category)
  end

  def self.update_category(category)
    Rails.application.config.kavau.send("#{category}=", Setting.where(category: category).to_hash[category.to_sym])
  end
end
