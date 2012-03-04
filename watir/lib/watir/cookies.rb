require "uri"

module Watir
  class Cookies
    include Enumerable

    def initialize(page_container)
      @page_container = page_container
    end

    def each
      @page_container.document.cookie.split(";").each do |cookie|
        name, value = cookie.strip.split("=")
        yield({:name => name, :value => value})
      end
    end

    def add name, value, options={}
      options = options.map do |option|
        k, v = option
        if k == :expires
          "#{k}=#{v.gmtime.strftime("%a, %-d %b %Y %H:%M:%S UTC")}"
        elsif k == :secure
          "secure" if v
        else
          "#{k}=#{v}"
        end
      end.compact.join("; ")

      options = "; #{options}" unless options.empty?
      @page_container.document.cookie = "#{name}=#{value}#{options}" 
    end

    def delete name
      options = {:expires => Time.now - 60 * 60 * 24}
      delete_with_options name, options

      # make sure that the cookie gets deleted
      # there's got to be some easier way to do this
      uri = URI.parse(@page_container.url)
      domain = uri.host

      paths = uri.path.split("/").reduce([]) do |paths, path|
        paths << "#{paths.last}/#{path}".squeeze("/")
      end << "/"

      subdomains = domain.split(".").reverse.reduce([]) do |subdomains, part|
        subdomain = "#{part}#{subdomains.last}"
        subdomain = "." + subdomain unless subdomain == domain
        subdomains << subdomain
      end

      subdomains.each do |subdomain|
        domain_options = options.merge :domain => subdomain
        delete_with_options name, domain_options
        delete_with_options name, domain_options.merge(:secure => true)

        paths.each do |path|
          path_options = options.merge :path => path
          delete_with_options name, path_options 
          delete_with_options name, path_options.merge(:secure => true)

          path_domain_options = domain_options.merge :path => path
          delete_with_options name, path_domain_options 
          delete_with_options name, path_domain_options.merge(:secure => true)
        end
      end
    end

    def clear
      each {|cookie| delete cookie[:name]}
    end

    def delete_with_options name, options={}
      add name, nil, options
    end

    private :delete_with_options
  end
end
