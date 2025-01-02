module DateTimeHelper
  def display_date(datetime = Date.current, format = nil)
    strtime = format_date[format] || '%d/%m/%Y'
    datetime.strftime(strtime)
  end

  def display_time(datetime = DateTime.current, format = nil)
    strtime = format_time[format] || '%H:%M'
    datetime.strftime(strtime)
  end

  def display_datetime(datetime = DateTime.current, format = nil)
    strtime = format_datetime[format] || '%d/%m/%Y %H:%M'
    datetime.strftime(strtime)
  end

  private

  def format_date
    {
      dmy_dashed: '%Y-%m-%d',
      dmy_slash: '%d/%m/%Y',
      dBy: '%d %B %Y',
      dby: '%d %b %Y'
    }
  end

  def format_time
    {
      hm24: '%H:%M',
      hm12: '%I:%M',
      hms24: '%H:%M:%S',
      hms12: '%I:%M:%S'
    }
  end

  def format_datetime
    {
      dmy_hm24: '%d/%m/%Y %H:%M',
      dmy_hm12: '%d/%m/%Y %I:%M',
      dmy_hms24: '%d/%m/%Y %H:%M:%S',
      dmy_hms12: '%d/%m/%Y %I:%M:%S'
    }
  end
end
