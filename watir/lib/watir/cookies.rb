require "uri"

module Watir
  class Cookies
    include Enumerable

    def initialize(page_container)
      @page_container = page_container
    end

    def each
      @page_container.document.cookie.split("; ").each do |cookie|
        name, value = cookie.split("=")
        yield({:name => name, :value => value})
      end
    end

    def add name, value, options={}
      options = options.map do |option|
        k, v = option
        case k
        when :expires
          "#{k}=#{v.gmtime.strftime("%a, %-d %b %Y %H:%M:%S UTC")}"
        when :secure
          "secure"
        else
          "#{k}=#{v}"
        end
      end.join("; ")

      options = "; #{options}" unless options.empty?
      @page_container.document.cookie = "#{name}=#{value}#{options}" 
    end

    def delete name, options={}
      add name, nil, options.merge(:expires => Time.now - 1000)
    end

    def clear options={}
      each do |cookie|
        delete cookie[:name], options
      end
    end
  end
end
