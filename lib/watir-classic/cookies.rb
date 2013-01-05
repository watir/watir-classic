require "uri"

module Watir
  # Returned by {IE#cookies}.
  class Cookies
    include Enumerable

    def initialize(page_container)
      @page_container = page_container
    end

    # Iterate over each cookie. 
    #
    # @example
    #   browser.cookies.each do |cookie|
    #     puts cookie[:name]
    #     puts cookie[:value]
    #   end
    #
    # @yieldparam [Hash] cookie name and value pair of the cookie.
    def each
      @page_container.document.cookie.split(";").each do |cookie|
        name, value = cookie.strip.split("=")
        yield({:name => name, :value => value})
      end
    end

    # Add a cookie.
    #
    # @example Add a cookie with default options:
    #   browser.cookies.add "name", "value'
    #
    # @example Add a cookie with options:
    #   browser.cookie.add "name", "value", :expires => Time.now, :secure => true, :path => "/foo/bar"
    #
    # @param [String] name name of the cookie.
    # @param [String] value value of the cookie.
    # @param [Hash] options options for the cookie.
    # @option options [Time] :expires Expiration time.
    # @option options [Boolean] :secure (false) Secure flag. Set when value is true.
    # @option options [String] :path Path for cookie.
    def add(name, value, options={})
      options = options.map do |option|
        k, v = option
        if k == :expires
          "#{k}=#{v.gmtime.strftime("%a, %d %b %Y %H:%M:%S UTC")}"
        elsif k == :secure
          "secure" if v
        else
          "#{k}=#{v}"
        end
      end.compact.join("; ")

      options = "; #{options}" unless options.empty?
      @page_container.document.cookie = "#{name}=#{value}#{options}" 
    end

    # Delete a cookie.
    #
    # @note does not raise any exceptions when cookie with the specified name is not found.
    #
    # @param [String] name Cookie with the specified name to be deleted.
    def delete(name)
      options = {:expires => ::Time.now - 60 * 60 * 24}
      delete_with_options name, options

      # make sure that the cookie gets deleted
      # there's got to be some easier way to do this
      uri = URI.parse(@page_container.url)
      domain = uri.host
      return unless domain

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

    # Delete all cookies for the page.
    def clear
      each {|cookie| delete cookie[:name]}
    end

    private

    def delete_with_options name, options={}
      add name, nil, options
    end

  end
end
