require 'identity_code/version'
require 'identity_code/ee'
require 'identity_code/lv'

module IdentityCode
  NUM_DAYS = {
    1 => 31,
    2 => 28,
    3 => 31,
    4 => 30,
    5 => 31,
    6 => 30,
    7 => 31,
    8 => 31,
    9 => 30,
    10 => 31,
    11 => 30,
    12 => 31
  }

  def self.age_correction(birth_date)
    now = Time.now.utc.to_date
    return 0 if now.month > birth_date.month
    return 0 if now.month == birth_date.month && now.day >= birth_date.day
    1
  end
end
