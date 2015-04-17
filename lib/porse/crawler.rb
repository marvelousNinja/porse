require 'mechanize'

class Crawler
  attr_accessor :agent

  def initialize
    @agent = Mechanize.new
  end

  def process(urls)
    previous_hash = nil

    urls.to_enum.each do |url|
      page = open(url)
      hash = page.body.hash
      break if previous_hash == hash
      yield page.body
      previous_hash = hash
    end
  end

  def open(url)
    agent.get(url)
  end
end
