module Podrick
  class Episode
    attr_reader :xml_doc, :images

    def initialize xml_doc
      @xml_doc = xml_doc
      @images = []
    end

    %w[title link guid author].each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method}
          instance_variable_get("@#{method}") || instance_variable_set("@#{method}", xml_content_at("#{method}"))
        end
      RUBY
    end

    def description
      @description ||= load_without_images("description")
    end

    def published_date
      @published_date ||= Time.parse(xml_doc.at_xpath("pubDate").content)
    end

    alias pubDate published_date

    def content
      @content ||= content_without_images
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

    def add_image url, width = nil, height = nil
      image_struct = Struct.new(:url, :width, :height)

      @images << image_struct.new(url, width, height)
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

    private

    def content_without_images
      begin
        load_without_images("content:encoded")
      rescue Nokogiri::XML::XPath::SyntaxError
        nil
      end
    end

    def load_without_images node_name
      node = xml_node_at(node_name)

      return nil if node.nil?

      html = Nokogiri::HTML(node.content)
      html.xpath("//img").each do |img|
        if img.key?("src")
          url = img["src"]
          height = img["height"]
          width = img["width"]

          add_image(url, width, height)
        end

        img.remove
      end

      html.to_html
    end
  end
end
