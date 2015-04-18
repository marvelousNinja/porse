require 'mechanize'

module Porse
  class Crawler
    attr_accessor :agent, :settings

    def initialize(settings = {})
      @agent = Mechanize.new
      @settings = settings
    end

    def process(urls)
      configure(urls, settings)

      previous_hash = nil

      urls.to_enum.each do |url|
        page = open(url)
        hash = page.body.hash
        break if previous_hash == hash
        yield page
        previous_hash = hash
      end
    end

    def open(url)
      agent.get(url)
    end

    def configure(urls, settings)
      if settings[:homepage_cookies]
        url = urls.to_enum.first
        uri = URI.parse(url)
        open("#{uri.scheme}://#{uri.host}")
      end
    end
  end
end
