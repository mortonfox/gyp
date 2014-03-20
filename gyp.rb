# Parse the Geocaching - Your Profile page and output a list of cache finds
# in a format suitable for posting to Livejournal.
#
# Author: Po Shan Cheah http://mortonfox.com
# Last updated: March 19, 2014

require 'nokogiri'
require 'date'
require 'getoptlong'

# Parse the logs table and extract only the cache finds.
def parse_file io
  Nokogiri.HTML(io).css('table')[1].css('tr').map { |tr_elem|
    if tr_elem.css('img').first['title'].to_s.downcase == 'found it'
      td_elems = tr_elem.css 'td'

      date_str = td_elems[1].text.strip
      date = Date.strptime date_str, '%m/%d/%Y'

      cache_elem = td_elems[2].css('a').last
      cache_name = cache_elem.text.strip
      cache_link = cache_elem['href']

      state = td_elems[3].text.strip

      {
        date: date,
        name: cache_name,
        state: state,
        link: cache_link
      }
    else
      nil
    end
  }.compact.reverse
end

# Output the cache list in a format suitable for pasting into Livejournal.
def output_caches cache_list, start_date, end_date
  puts <<-EOM
<lj-cut text="The caches...">
<div style="margin: 10px 30px; border: 1px dashed; padding: 10px;">
  EOM

  curdate = nil

  cache_list.each { |cache|
    date = cache[:date]
    if date >= start_date and date <= end_date

      # Output a date header every time we get to a new day.
      if date != curdate
        puts <<-EOM

#{date.strftime '%A %Y-%m-%d'}:

        EOM
        curdate = date
      end
      puts <<-EOM
<a href=\"#{cache[:link]}\">#{cache[:name]} (#{cache[:state]})</a>
      EOM
    end
  }

  puts <<-EOM
</div>
</lj-cut>
  EOM
end

# Process date range command line arguments.
def get_date_range start_date_str, end_date_str
  start_date = start_date_str ? Date.parse(start_date_str) : nil
  end_date = end_date_str ? Date.parse(end_date_str) : nil

  if start_date
    # End of date range defaults to today.
    end_date ||= Date.today
  else
    # If date range not specified, use the most recent weekend.
    today = Date.today
    mod_saturday = (today.wday - 6) % 7

    # If today is Saturday, we want the previous full weekend.
    mod_saturday = 7 if mod_saturday == 0

    start_date = today - mod_saturday
    end_date = start_date + 1
  end

  # For sake of sanity, swap date range if reversed.
  start_date, end_date = end_date, start_date if start_date > end_date

  [ start_date, end_date ]
end

def stream_file input_file
  if input_file and input_file != '-'
    open(input_file) { |io|
      yield io
    }
  else
    yield $stdin
  end
end

USAGE = <<-EOM
Usage: #{$PROGRAM_NAME} [-h|--help] [input-file] [start-date] [end-date]

    input-file:
        Name of input file. (Default: read from stdin)

    start-date:
        Start of date range to process.

    end-date:
        End of date range to process.

    Recommended format for dates is YYYY-MM-DD.
    If start date is not specified, process the most recent weekend.
    If start date is specified but not end date, the end date defaults to today.
EOM

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ]
)
opts.quiet = true

begin
  opts.each { |opt, arg|
    case opt
    when '--help'
      puts USAGE
      exit 0
    end
  }
rescue GetoptLong::Error => err
  $stderr.puts "Error from GetoptLong: #{err}"
  $stderr.puts USAGE
  exit 1
end

input_file, start_date_str, end_date_str = ARGV
start_date, end_date = get_date_range start_date_str, end_date_str

cache_list = stream_file(input_file) { |io| parse_file io }
output_caches cache_list, start_date, end_date
__END__
