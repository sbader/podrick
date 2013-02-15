require 'faraday'
require 'nokogiri'

module Podrick
  class Podcast
    attr_reader :etag

    def initialize xml_string, etag = nil
      @xml = xml_string
      @etag = etag
    end

    def self.from_xml xml_string, etag = nil
      new(xml_string, etag)
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
        new(response.body, response.headers['ETag'])
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
      @itunes ||= begin
        image = Struct.new(:href)
        owner = Struct.new(:name, :email)
        itunes = Struct.new(:subtitle, :author, :summary, :keywords, :explicit, :category, :subcategories, :image, :owner)

        itunes.new(
          xml_doc.at_xpath("//itunes:subtitle").content,
          xml_doc.at_xpath("//itunes:author").content,
          xml_doc.at_xpath("//itunes:summary").content,
          xml_doc.at_xpath("//itunes:keywords").content,
          xml_doc.at_xpath("//itunes:explicit").content,
          xml_doc.at_xpath("//itunes:category")["text"],
          xml_doc.xpath("//itunes:category//itunes:category").map { |category| category["text"] },
          image.new(xml_doc.at_xpath("//itunes:image")["href"]),
          owner.new(xml_doc.at_xpath("//itunes:owner//itunes:name").content, xml_doc.at_xpath("//itunes:owner//itunes:email").content)
        )
      end
    end

    def episodes
      @episodes ||= xml_doc.xpath('//item').map { |item_xml| Episode.new(item_xml) }
    end
  end
end
