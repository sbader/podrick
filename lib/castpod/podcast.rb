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

    %w[link title description language].each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method}
          instance_variable_get("@#{method}") || instance_variable_set("@#{method}", xml_attr_at_path("#{method}").content)
        end
      RUBY
    end

    %w[itunes_subtitle itunes_author itunes_summary itunes_keywords itunes_explicit itunes_image].each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method}
          instance_variable_get("@#{method}") || instance_variable_set("@#{method}", xml_attr_at_path("#{method.tr("_", ":")}").content)
        end
      RUBY
    end

    def itunes_image
      @itunes_image ||= xml_attr_at_path("itunes:image")["href"]
    end

    def itunes_category
      @itunes_category ||= xml_attr_at_path("itunes:category")["text"]
    end

    def itunes_subcategories
      @itunes_subcategories ||= xml_collection_at_path("itunes:category//itunes:category").map { |category| category["text"] }
    end

    def itunes_owner_name
      @itunes_owner_name ||= xml_attr_at_path("itunes:owner//itunes:name").content
    end

    def itunes_owner_email
      @itunes_owner_email ||= xml_attr_at_path("itunes:owner//itunes:email").content
    end

    def pub_date
      @pub_date ||= Time.parse(xml_attr_at_path('pubDate').content).utc
    end

    def xml_attr_at_path name
      xml_doc.at_xpath("//#{name}")
    end

    def xml_collection_at_path name
      xml_doc.xpath("//#{name}")
    end
  end
end
