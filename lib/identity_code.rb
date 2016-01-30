require 'identity_code/version'
require 'date'

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

  class EE
    HOSPITALS = [
      '00', # Kuressaare Haigla (järjekorranumbrid 001 kuni 020)
      '01', # Tartu Ülikooli Naistekliinik, Tartumaa, Tartu (011...019)
      '02', # Ida-Tallinna Keskhaigla, Hiiumaa, Keila, Rapla haigla (021...220)
      '22', # Ida-Viru Keskhaigla (Kohtla-Järve, endine Jõhvi) (221...270)
      '27', # Maarjamõisa Kliinikum (Tartu), Jõgeva Haigla (271...370)
      '37', # Narva Haigla (371...420)
      '42', # Pärnu Haigla (421...470)
      '47', # Pelgulinna Sünnitusmaja (Tallinn), Haapsalu haigla (471...490)
      '49', # Järvamaa Haigla (Paide) (491...520)
      '52', # Rakvere, Tapa haigla (521...570)
      '57', # Valga Haigla (571...600)
      '60', # Viljandi Haigla (601...650)
      '65', # Lõuna-Eesti Haigla (Võru), Pälva Haigla (651...710?)
      '70', # All other hospitals
      '95'  # Foreigners who are born in Estonia
    ]

    def self.generate(opts = {})
      first_digit = 0

      sex = opts[:sex] || (rand.round == 0 ? 'M' : 'F')
      year = opts[:year] || rand(Date.today.year - 90..Date.today.year - 1)
      year = rand(Date.today.year - 50..Date.today.year - 19) if opts[:safe_age]
      month = opts[:month] || rand(1..12)
      day = opts[:day] || rand(1..NUM_DAYS[month])

      first_digit += 1 if (1800..1899).include?(year)
      first_digit += 3 if (1900..1999).include?(year)
      first_digit += 5 if year >= 2000
      first_digit += 1 if sex == 'F'

      result = first_digit.to_s
      result += "%02d" % year.to_s[2..3].to_i
      result += "%02d" % month
      result += "%02d" % day
      result += HOSPITALS[(rand * HOSPITALS.size - 1).round]
      result += rand(0..9).to_s
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
      year = century + @code[1..2].to_i
      month = @code[3..4].to_i
      day = @code[5..6].to_i
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
      @code[0].to_i.odd? ? 'M' : 'F'
    end

    def control_code
      scales1 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 1]
      checknum = scales1.each_with_index.map do |scale, i|
        @code[i].chr.to_i * scale
      end.inject(0, :+) % 11
      return checknum unless checknum == 10

      scales2 = [3, 4, 5, 6, 7, 8, 9, 1, 2, 3]
      checknum = scales2.each_with_index.map do |scale, i|
        @code[i].chr.to_i * scale
      end.inject(0, :+) % 11

      checknum == 10 ? 0 : checknum
    end

    private

    def age_correction
      now = Time.now.utc.to_date
      return 0 if now.month > birth_date.month
      return 0 if now.month == birth_date.month && now.day >= birth_date.day
      1
    end

    def century
      case @code[0].chr.to_i
      when 1..2 then 1800
      when 3..4 then 1900
      when 5..6 then 2000
      else
        2100
      end
    end
  end

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
      result += century_code
      result += "%03d" % rand(0..999).to_s
      result += new(result).control_code.to_s
    end

    def self.valid?(code)
      new(code).valid?
    end

    def valid?
      @code.length == 11 &&
      @code[10].chr.to_i == control_code
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
      now.year - (birth_date.year + age_correction)
    end

    def control_code
      array = @code.split('').map(&:to_i)
      multipliers = [1, 6, 3, 7, 9, 10, 5, 8, 4, 2]
      hash = Hash[multipliers.zip(array)]

      check = 0
      hash.map do |k, v|
        check += k * v
      end

      ((1 - check) % 11) % 10
    end

    private

    def age_correction
      now = Time.now.utc.to_date
      return 0 if now.month > birth_date.month
      return 0 if now.month == birth_date.month && now.day >= birth_date.day
      1
    end

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
