require 'date'

module IdentityCode
  class LV
    def initialize(code)
      @code = code.to_s.gsub('-', '')
    end

    def self.generate(opts = {})
      year = opts[:year] || rand(Date.today.year - 90..Date.today.year - 1)
      year = rand(Date.today.year - 50..Date.today.year - 19) if opts[:safe_age]
      month = opts[:month] || rand(1..12)
      day = opts[:day] || rand(1..NUM_DAYS[month])

      century_code = begin
        case year
        when 1800..1899 then 0
        when 1900..1999 then 1
        when 2000..2099 then 2
        else
          9
        end
      end.to_s

      result = "%02d" % day
      result += "%02d" % month
      result += "%02d" % year.to_s[2..3].to_i
      result += '-' if opts[:separator]
      result += century_code.to_s
      result += "%03d" % rand(1..999).to_s
      result += control_digit(result).to_s
    end

    def self.valid?(code)
      new(code).valid?
    end

    def self.control_digit(base)
      array = base.gsub('-', '').split('').map(&:to_i)
      multipliers = [1, 6, 3, 7, 9, 10, 5, 8, 4, 2]
      hash = Hash[multipliers.zip(array)]

      check = 0
      hash.map do |k, v|
        check += k * v
      end

      ((1 - check) % 11) % 10
    end

    def valid?
      @code.length == 11 &&
      @code[10].chr.to_i == self.class.control_digit(@code)
    end

    def birth_date
      return unless valid?
      year = century + @code[4..5].to_i
      month = @code[2..3].to_i
      day = @code[0..1].to_i
      return unless Date.valid_date?(year, month, day)
      Date.new(year, month, day)
    end

    def age
      return unless valid?
      now = Time.now.utc.to_date
      now.year - (birth_date.year + IdentityCode.age_correction(birth_date))
    end

    private

    def century
      case @code[6].chr.to_i
      when 0 then 1800
      when 1 then 1900
      when 2 then 2000
      else
        2100
      end
    end
  end
end
