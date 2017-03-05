require 'date'

module IdentityCode
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

      sex = opts[:sex] || (rand.round == 0 ? :M : :F)
      year = opts[:year] || rand(Date.today.year - 90..Date.today.year - 1)
      year = rand(Date.today.year - 50..Date.today.year - 19) if opts[:safe_age]
      month = opts[:month] || rand(1..12)
      day = opts[:day] || rand(1..NUM_DAYS[month])

      first_digit += 1 if (1800..1899).include?(year)
      first_digit += 3 if (1900..1999).include?(year)
      first_digit += 5 if year >= 2000
      first_digit += 1 if sex.upcase.to_sym == :F

      result = first_digit.to_s
      result += "%02d" % year.to_s[2..3].to_i
      result += "%02d" % month
      result += "%02d" % day
      result += HOSPITALS[(rand * HOSPITALS.size - 1).round]
      result += rand(0..9).to_s
      result += control_digit(result).to_s
    end

    def self.valid?(code)
      new(code).valid?
    end

    def self.control_digit(base)
      scales1 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 1]
      checknum = scales1.each_with_index.map do |scale, i|
        base[i].chr.to_i * scale
      end.inject(0, :+) % 11
      return checknum unless checknum == 10

      scales2 = [3, 4, 5, 6, 7, 8, 9, 1, 2, 3]
      checknum = scales2.each_with_index.map do |scale, i|
        base[i].chr.to_i * scale
      end.inject(0, :+) % 11

      checknum == 10 ? 0 : checknum
    end

    def initialize(code)
      @code = code.to_s
    end

    def valid?
      @code.length == 11 &&
      @code[10].chr.to_i == self.class.control_digit(@code)
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
      now.year - (birth_date.year + IdentityCode::age_correction(birth_date))
    end

    def sex
      return unless valid?
      @code[0].to_i.odd? ? :M : :F
    end

    private

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
end
