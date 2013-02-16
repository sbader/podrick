module Podrick
  class Episode
    attr_reader :xml_doc

    def initialize xml_doc
      @xml_doc = xml_doc
    end

    %w[title link guid author description].each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method}
          instance_variable_get("@#{method}") || instance_variable_set("@#{method}", xml_content_at("#{method}"))
        end
      RUBY
    end

    def published_date
      @published_date ||= Time.parse(xml_doc.at_xpath("pubDate").content)
    end

    alias pubDate published_date

    def content
      @content ||= xml_content_at("content:encoded")
    end

    def enclosure
      @enclosure ||= begin
        enclosure_struct = Struct.new(:url, :length, :type)
        enclosure = xml_doc.at_xpath("enclosure")
        if enclosure
          enclosure_struct.new(
            enclosure["url"],
            enclosure["length"],
            enclosure["type"]
          )
        else
          enclosure_struct.new(nil, nil, nil)
        end
      end
    end

    def itunes
      @itunes ||= begin
        image = Struct.new(:href)
        itunes = Struct.new(:author, :duration, :subtitle, :summary, :keywords, :image)
        image_href = (node = xml_node_at("itunes:image")) ? node["href"] : nil

        itunes.new(
          xml_content_at("itunes:author"),
          xml_content_at("itunes:duration"),
          xml_content_at("itunes:subtitle"),
          xml_content_at("itunes:summary"),
          xml_content_at("itunes:keywords"),
          image.new(image_href)
        )
      end
    end

    def xml_content_at string
      begin
        if node = xml_doc.at_xpath(string)
          node.content
        end
      rescue Nokogiri::XML::XPath::SyntaxError
        nil
      end
    end

    def xml_node_at string
      if node = xml_doc.at_xpath(string)
        node
      end
    end
  end
end
