class Setting < ActiveRecord::Base
  validates :key, presence: true

  def self.get(key)
    where(key: key).first.value
  end

  def self.set(key, value)
    where(key: key).first.update_attribute :value, value
  end
end
