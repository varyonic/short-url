class ShortenedUrl < ActiveRecord::Base

  NotFound = Class.new StandardError

  SERVICE_HOSTNAME = ['localhost','va.ry']
  BASE10 = "0123456789"
  BASE16 = "0123456789abcdef"
  BASE36 = "0123456789abcdefghijklmnopqrstuvwxyz"

  # drop O as ambiguous with 0
  BASE35 = "0123456789abcdefghijklmnpqrstuvwxyz"

  class << self
    # Shorten a long URI, lengthen a short URI
    def map(uri) short_uri?(uri) ? lengthen(uri) : shorten(uri) end

    def short_uri? s
      # FIXME: for some reason the URI is passed in as http:/va.ry/1 ??
      s.sub!("://",":/")
      s.sub!(":/",'://')
      SERVICE_HOSTNAME.include?(URI.parse(s).host)
    end

    # Lookup short URI, raises NotFound if not found.
    def lengthen uri
      s = URI.parse(uri).path.sub('/','')
      find( decode s ).full_url
    rescue
      raise NotFound, s
    end

    def shorten(uri)
      surl = find_by_full_url(uri) || create(full_url: uri)
      "http://va.ry/#{encode(surl.id)}"
    end

    def encode n, base = BASE35
      s = ""
      div = 1; div *= base.length while div * base.length <= n
      s.concat base.slice(n/div)
      while div > 1
        n = n % div
        div /= base.length
        s.concat base.slice(n/div)
      end
      s
    end

    def decode s, base = BASE35
      s.gsub!('O','0') if base == BASE35
      n = 0; div = 1
      s.downcase.reverse!.each_char do |c|
        n += base.index(c) * div
        div *= base.length
      end
      n
    end
  end

  attr_accessible :full_url

end
