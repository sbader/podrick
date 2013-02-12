require 'nokogiri'

module Castpod
  class Itunes
    attr_reader :xml_doc

    def initialize xml_doc
      @xml_doc = xml_doc
    end

    %w[subtitle author summary keywords explicit].each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method}
          instance_variable_get("@#{method}") || instance_variable_set("@#{method}", xml_doc.at_xpath("//itunes:#{method}").content)
        end
      RUBY
    end

    def image
      @image ||= begin
        image = Struct.new(:href)
        image.new(xml_doc.at_xpath("//itunes:image")["href"])
      end
    end

    def owner
      @owner ||= begin
        owner = Struct.new(:name, :email)
        owner.new(xml_doc.at_xpath("//itunes:owner//itunes:name").content, xml_doc.at_xpath("//itunes:owner//itunes:email").content)
      end
    end

    def category
      @category ||= xml_doc.at_xpath('//itunes:category')["text"]
    end

    def subcategories
      @subcategories ||= xml_doc.xpath("//itunes:category//itunes:category").map { |category| category["text"] }
    end
  end
end

