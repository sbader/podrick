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

      if response.status == 304
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
          instance_variable_get("@#{method}") || instance_variable_set("@#{method}", xml_content_at("//#{method}"))
        end
      RUBY
    end

    def itunes
      @itunes ||= begin
        image = Struct.new(:href)
        owner = Struct.new(:name, :email)
        itunes = Struct.new(:subtitle, :author, :summary, :keywords, :explicit, :category, :subcategories, :image, :owner)

        itunes.new(
          xml_content_at("//itunes:subtitle"),
          xml_content_at("//itunes:author"),
          xml_content_at("//itunes:summary"),
          xml_content_at("//itunes:keywords"),
          xml_content_at("//itunes:explicit"),
          xml_node_at("//itunes:category")["text"],
          xml_doc.xpath("//itunes:category//itunes:category").map { |category| category["text"] },
          image.new(xml_node_at("//itunes:image")["href"]),
          owner.new(xml_content_at("//itunes:owner//itunes:name"), xml_content_at("//itunes:owner//itunes:email"))
        )
      end
    end

    def xml_content_at string
      if node = xml_metadata.at_xpath(string)
        node.content
      end
    end

    def xml_node_at string
      if node = xml_metadata.at_xpath(string)
        node
      end
    end

    def episodes
      @episodes ||= xml_doc.xpath('//item').map { |item_xml| Episode.new(item_xml) }
    end
  end
end
