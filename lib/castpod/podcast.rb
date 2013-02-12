require 'faraday'
require 'nokogiri'

module Castpod
  class Podcast
    def initialize xml_string
      @xml = xml_string
    end

    def self.from_xml xml_string
      new(xml_string)
    end

    def self.from_url url, etag = nil
      headers = {}

      if etag
        headers['If-None-Match'] = etag
      end

      response = Faraday.get(url, {}, headers)

      if response.status == '301'
        nil
      else
        new(response.body)
      end
    end

    def xml_doc
      @xml_doc ||= Nokogiri::XML(@xml)
    end

    def xml_metadata
      @xml_metadata ||= xml_doc.xpath('/rss/channel/*[not(self::item)]')
    end

    %w[link title description language].each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method}
          instance_variable_get("@#{method}") || instance_variable_set("@#{method}", xml_metadata.at_xpath("//#{method}").content)
        end
      RUBY
    end

    def itunes
      @itunes ||= Itunes.new(xml_metadata)
    end

    def episodes
      @episodes ||= xml_doc.xpath('//item').map { |item_xml| Episode.new(item_xml) }
    end
  end
end
