require 'identity_code/version'
require 'date'

module IdentityCode
  class Isikukood
    attr_reader :code

    def initialize(code)
      @code = code.to_s
    end

    def valid?
      code.length == 11 &&
      code[10].chr.to_i == control_code
    end

    def birth_date
      return unless valid?
      year = century + code[1..2].to_i
      month = code[3..4].to_i
      day = code[5..6].to_i
      return unless Date.valid_date?(year, month, day)
      Date.new(year, month, day)
    end

    def age
      return unless valid?
      now = Time.now.utc.to_date
      now.year - (birth_date.year + age_correction)
    end

    def sex
      return unless valid?
      code[0].to_i.odd? ? 'M' : 'F'
    end

    private

    def control_code
      scales1 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 1]
      checknum = scales1.each_with_index.map do |scale, i|
        code[i].chr.to_i * scale
      end.inject(0, :+) % 11
      return checknum unless checknum == 10

      scales2 = [3, 4, 5, 6, 7, 8, 9, 1, 2, 3]
      checknum = scales2.each_with_index.map do |scale, i|
        code[i].chr.to_i * scale
      end.inject(0, :+) % 11

      checknum == 10 ? 0 : checknum
    end

    def age_correction
      now = Time.now.utc.to_date
      return 0 if now.month > birth_date.month
      return 0 if now.month == birth_date.month && now.day >= birth_date.day
      1
    end

    def century
      case code[0].chr.to_i
      when 1..2 then 1800
      when 3..4 then 1900
      when 5..6 then 2000
      else
        2100
      end
    end
  end
end
