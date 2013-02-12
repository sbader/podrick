module Castpod
  class Episode
    attr_reader :xml_doc

    def initialize xml_doc
      @xml_doc = xml_doc
    end

    %w[title link guid author description].each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method}
          instance_variable_get("@#{method}") || instance_variable_set("@#{method}", @xml_doc.at_xpath("#{method}").content)
        end
      RUBY
    end

    def published_date
      @published_date ||= Time.parse(xml_doc.at_xpath("pubDate").content)
    end

    alias pubDate published_date

    def content
      @content ||= xml_doc.at_xpath("content:encoded").content
    end

    def enclosure
      @enclosure ||= begin
        enclosure_struct = Struct.new(:url, :length, :type)
        enclosure = xml_doc.at_xpath("enclosure")
        enclosure_struct.new(enclosure["url"], enclosure["length"], enclosure["type"])
      end
    end

    def itunes
      @itunes ||= begin
        image = Struct.new(:href)
        itunes = Struct.new(:author, :duration, :subtitle, :summary, :keywords, :image)

        itunes.new(
          xml_doc.at_xpath("itunes:author").content,
          xml_doc.at_xpath("itunes:duration").content,
          xml_doc.at_xpath("itunes:subtitle").content,
          xml_doc.at_xpath("itunes:summary").content,
          xml_doc.at_xpath("itunes:keywords").content,
          image.new(xml_doc.at_xpath("itunes:image")["href"])
        )
      end
    end
  end
end
