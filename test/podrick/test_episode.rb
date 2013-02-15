require 'helper'

module Podrick
  class TestEpisode < MiniTest::Unit::TestCase
    describe "episode loading" do
      it "loads the metadata from a nokogiri xml doc" do
        item_xml = Nokogiri::XML(File.read('test/assets/back_to_work.xml')).at_xpath("//item")
        episode = Episode.new(item_xml)

        assert_equal "Back to Work 105: Fissures of Men", episode.title
        assert_equal "http://5by5.tv/b2w/105", episode.link
        assert_equal "http://5by5.tv/b2w/105", episode.guid
        assert_equal Time.parse("2013-02-05 20:30:00 GMT"), episode.published_date
        assert episode.description.include?("he and Dan talk about a bunch of cool apps")
        assert_equal "http://d.ahoy.co/redirect.mp3/fly.5by5.tv/audio/broadcasts/b2w/2013/b2w-105.mp3", episode.enclosure.url
        assert_equal "40815332", episode.enclosure.length
        assert_equal "audio/mpeg", episode.enclosure.type
        assert episode.content.include?("<p>This week, Merlin is delirious and may be in a fugue state, so he and Dan talk about a bunch of cool apps and gadgets--stuff that Merlin likes and really recommends.</p>")
        assert_equal "Merlin Mann & Dan Benjamin", episode.itunes.author
        assert_equal "1:24:27", episode.itunes.duration
        assert_equal "TOPIC: Cool stuff Merlin loves.", episode.itunes.subtitle
        assert episode.itunes.summary.include?("This week, Merlin is delirious and may be in a fugue state, so he and Dan talk about a bunch of cool apps")
        assert_equal "productivity, communication, work, barriers, constraints, tools, gadgets", episode.itunes.keywords
        assert_equal "http://icebox.5by5.tv/images/broadcasts/19/cover.jpg", episode.itunes.image.href
      end

      # it "downloads the enclosure" do
      # end
    end
  end
end
