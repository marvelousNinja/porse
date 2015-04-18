module Porse
  class UrlGenerator
    attr_accessor :starting_url, :param_name, :current_uri

    def initialize(starting_url, param_name)
      @starting_url = starting_url.to_str
      @param_name = param_name
      rewind
    end

    def next_url
      query = URI.decode_www_form(current_uri.query || '')
      param, value = query.find { |pair| pair.first == param_name }
      query.delete([param, value])
      query << [param || param_name, value.to_i + 1]
      current_uri.query = URI.encode_www_form(query)
      current_uri.to_s
    end

    def rewind
      @current_uri = URI.parse(starting_url)
      @current_uri.scheme ||= 'http'
    end

    def to_enum
      Enumerator.new do |y|
        rewind
        loop { y << next_url }
      end
    end
  end
end
