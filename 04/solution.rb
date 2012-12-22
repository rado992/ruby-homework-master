class Validations
  def self.email?(value)
    (/(?x)\A[A-Za-z0-9][\w|\.|\+|\-]{,200}[\@]
    ([A-Za-z0-9][A-Za-z0-9\-]{,60}([A-Za-z0-9]?\.)){1,2}
    (([A-Za-z]{2,3})(\z|\.[A-Za-z]{2}\z))/.match value) ? true : false
  end

  def self.hostname?(value)
    (/(?x)\A([A-Za-z0-9][A-Za-z0-9\-]{,60}(([A-Za-z0-9]?)\.)){1,2}
    (([A-Za-z]{2,3})(\z|\.[A-Za-z]{2}\z))/.match value) ? true : false
  end

  def self.phone?(value)
    (/\A(?<prefix>(00|\+)[1-9][0-9]{,2}|[0])([ \(\)\-]{,2}[0-9]){6,11}\z/.match value) ? true : false
  end

  def self.ip_address?(value)
    (/\A(?<byte>[0-1]?[0-9]{1,2}|2([5][0-5]|[0-4][0-9]))\.\g<byte>\.\g<byte>\.\g<byte>\z/.match value) ? true : false
  end

  def self.number?(value)
    (/\A[\-]?(?<int>0|[1-9][0-9]*)(?<fract>\.[0-9]+)?\z/.match value) ? true : false
  end

  def self.integer?(value)
    (/\A[\-]?(?<int>0|[1-9][0-9]*)\z/.match value) ? true : false
  end

  def self.date?(value)
    (/\A[0-9]{4}\-(?<month>0[1-9]|1[0-2])\-(?<day>0[1-9]|[1-2][0-9]|3[0-1])\z/.match value) ? true : false
  end

  def self.time?(value)
    (/\A(?<hour>[0-1][0-9]|2[0-3])(?<minsec>:[0-5][0-9]){2}\z/.match value) ? true : false
  end

  def self.date_time?(value)
    (/(?x)\A[0-9]{4}\-(?<month>0[1-9]|1[0-2])\-(?<day>0[1-9]|[1-2][0-9]|3[0-1])[ \sT]
    (?<hour>[0-1][0-9]|2[0-3])(?<minsec>:[0-5][0-9]){2}\z/.match value) ? true : false
  end
end

class PrivacyFilter
  attr_accessor :preserve_phone_country_code, :preserve_email_hostname, :partially_preserve_email_username

  def initialize(text)
    @preserve_phone_country_code, @preserve_email_hostname, @partially_preserve_email_username = false, false, false
    @initial_text = text
  end

  def filtered
    filter_phones(filter_emails(@initial_text))
  end

  private
  def filter_emails(text)
    text.gsub(email_regex) do
      email_replacement($~)
    end
  end

  def filter_phones(text)
    text.gsub(phone_regex) do
      phone_replacement($~)
    end
  end

  def phone_regex
    /(?<prefix>(00|\+)[1-9][0-9]{,2}|[0])([ \(\)\-]{,2}[0-9]){6,11}/
  end

  def phone_replacement(matched)
    filtered, prefix = "[PHONE]", matched[:prefix] == "0" ? "" : matched[:prefix] + ' '
    if @preserve_phone_country_code then filtered = prefix + "[FILTERED]" end
    filtered
  end

  def email_regex
    /(?x)(?<mail>[A-Za-z0-9][\w|\.|\+|\-]{,200})(?<host>[\@]
    ([A-Za-z0-9][A-Za-z0-9\-]{,60}([A-Za-z0-9]?\.)){1,2}
    (([A-Za-z]{2,3})((\.[A-Za-z]{2})?)))/
  end

  def email_replacement(matched)
    filtered, name_first ="[EMAIL]", matched[:mail].length > 5 ? matched[:mail][0..2] : ""
    if @partially_preserve_email_username then filtered = name_first + "[FILTERED]" + matched[:host]
    elsif @preserve_email_hostname then filtered = "[FILTERED]" + matched[:host] end
    filtered
  end
end
