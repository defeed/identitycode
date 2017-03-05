require 'date'

module IdentityCode
  class PL
    def self.generate(opts = {})
      sex = opts[:sex] || (rand.round == 0 ? :M : :F)
      year = opts[:year] || rand(Date.today.year - 90..Date.today.year - 1)
      year = rand(Date.today.year - 50..Date.today.year - 19) if opts[:safe_age]
      month = opts[:month] || rand(1..12)
      calc_month = begin
        offset = case year.to_s[0..1]
          when '18' then 80
          when '19' then 0
          when '20' then 20
        end
        month + offset
      end
      day = opts[:day] || rand(1..NUM_DAYS[month])

      sex_digit = [0, 2, 4, 6, 8].sample
      sex_digit += 1 if sex.upcase.to_sym == :M

      result  = "%02d" % year.to_s[2..3].to_i
      result += "%02d" % calc_month
      result += "%02d" % day
      result += "%03d" % rand(1..999)
      result += sex_digit.to_s
      result += new(result).control_code.to_s
    end

    def self.valid?(code)
      new(code).valid?
    end

    def initialize(code)
      @code = code.to_s
    end

    def valid?
      @code.length == 11 &&
      @code[10].chr.to_i == control_code
    end

    def birth_date
      return unless valid?
      year = century + @code[0..1].to_i
      day = @code[4..5].to_i
      return unless Date.valid_date?(year, month, day)
      Date.new(year, month, day)
    end

    def month
      raw_num = @code[2..3].to_i

      case raw_num
      when 81..92 then raw_num - 80
      when 1..12  then raw_num
      when 21..32 then raw_num - 20
      end
    end

    def age
      return unless valid?
      now = Time.now.utc.to_date
      now.year - (birth_date.year + IdentityCode::age_correction(birth_date))
    end

    def sex
      return unless valid?
      @code[9].to_i.odd? ? :M : :F
    end

    def control_code
      multipliers = [9, 7, 3, 1, 9, 7, 3, 1, 9, 7]
      id_ary = @code.split(//).map(&:to_i)
      sum = 0

      (0...multipliers.count).each { |i| sum += id_ary[i] * multipliers[i] }

      sum % 10
    end

    private

    def century
      c = @code[2..3].to_i

      case c
      when 81..92 then 1800
      when 1..12  then 1900
      when 21..32 then 2000
      end
    end
  end
end

# CONTROL_SUM = [9, 7, 3, 1, 9, 7, 3, 1, 9, 7]
#
# def length_valid?
#   identity_code && identity_code.length == 11
# end
#
# def checksum_valid?
#   id_ary = identity_code.split(//).map(&:to_i)
#   sum = 0
#
#   (0...CONTROL_SUM.count).each { |i| sum += id_ary[i] * CONTROL_SUM[i] }
#
#   sum % 10 == id_ary[10]
# end
#
# def calculate_birthday
#   @birthday = Date.new(year, month, day)
# rescue
#   @birthday = nil
# end
# alias_method :birthday_valid?, :calculate_birthday
#
# def century
#   c = identity_code[2..3].to_i
#
#   case c
#   when 81..92
#     '18'
#   when 1..12
#     '19'
#   when 21..32
#     '20'
#   end
# end
#
# def year
#   (century + identity_code[0..1]).to_i
# end
#
# def month
#   raw_num = identity_code[2..3].to_i
#
#   case raw_num
#   when 81..92
#     raw_num - 80
#   when 1..12
#     raw_num
#   when 21..32
#     raw_num - 20
#   end
# end
#
# def day
#   identity_code[4..5].to_i
# end
#
# def available_gender
#   identity_code[9].to_i.even? ? :F : :M
# end
