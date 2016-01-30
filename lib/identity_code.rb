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
  }.freeze

  SUPPORTED_COUNTRY_CODES = %i(ee lv).freeze

  def self.generate(opts = {})
    country_code = opts.delete(:country)
    raise 'Country param is missing or invalid (ee or lv)' unless begin
      country_code &&
      SUPPORTED_COUNTRY_CODES.include?(country_code.downcase.to_sym)
    end

    Object.const_get("IdentityCode::#{country_code.upcase}").generate(opts)
  end

  def self.valid?(opts = {})
    country_code = opts.delete(:country)
    raise 'Country param is missing or invalid (ee or lv)' unless begin
      country_code &&
      SUPPORTED_COUNTRY_CODES.include?(country_code.downcase.to_sym)
    end

    code = opts.delete(:code)
    Object.const_get("IdentityCode::#{country_code.upcase}").valid?(code)
  end

  def self.age_correction(birth_date)
    now = Time.now.utc.to_date
    return 0 if now.month > birth_date.month
    return 0 if now.month == birth_date.month && now.day >= birth_date.day
    1
  end
end
