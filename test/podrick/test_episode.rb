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

      it "loads the metadata from another format" do
        item_xml = Nokogiri::XML(File.read('test/assets/radio_lab.xml')).at_xpath("//item")
        episode = Episode.new(item_xml)

        assert_equal "Speed\n", episode.title
        assert_equal "http://feeds.wnyc.org/~r/radiolab/~3/aD0MohGPUvo/", episode.link
        assert_equal "http://www.radiolab.org/2013/feb/05/", episode.guid
        assert_equal Time.parse("2013-02-05 17:35:00 -0500"), episode.published_date
        assert episode.description.include?("We live our lives at human speed, we experience and interact with the world")
        assert_equal "http://feeds.wnyc.org/~r/radiolab/~5/HrqM1JwInZE/radiolab020513.mp3", episode.enclosure.url
        assert_equal "0", episode.enclosure.length
        assert_equal "audio/mpeg", episode.enclosure.type
        assert_equal nil, episode.content
        assert_equal "Jad Abumrad & Robert Krulwich", episode.itunes.author
        assert_equal nil, episode.itunes.duration
        assert_equal " We live our lives at human speed, we experience and interact with the world on a human time scale. But this hour, we put ourselves through the paces, peek inside a microsecond, and master the fastest thing in the universe. ", episode.itunes.subtitle
        assert episode.itunes.summary.include?("We live our lives at human speed, we experience and interact with the world on a human time scale.")
        assert_equal "Science,Technology,Philosophy,Education,radiolab,jad,abumrad,krulwich,Radio,Lab", episode.itunes.keywords
        assert_equal nil, episode.itunes.image.href
      end

      # it "downloads the enclosure" do
      # end
    end
  end
end
