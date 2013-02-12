require 'helper'

module Castpod
  class TestPodcast < MiniTest::Unit::TestCase
    describe "podcast metadata loading" do
      it "loads the metadata from xml" do
        podcast = Podcast.from_xml(File.read('test/assets/back_to_work.xml'))
        assert_equal "Back to Work", podcast.title
        assert_equal "http://5by5.tv/b2w", podcast.link
        assert_equal Time.parse('2013-02-05 20:30:00 GMT').utc, podcast.pub_date

        description = "Back to Work is an award winning talk show with Merlin Mann and Dan Benjamin discussing productivity, communication, work, barriers, constraints, tools, and more. Hosted by Merlin Mann & Dan Benjamin."

        assert_equal description, podcast.description
        assert_equal "en-us", podcast.language

        # itunes info
        # assert_equal "http://feeds.5by5b.tv/b2w", podcast.itunes.new_feed_url
        # assert_equal "Back to Work", podcast.itunes_subtitle
        assert_equal "5by5", podcast.itunes_author
        assert_equal description, podcast.itunes_summary
        assert_equal "http://icebox.5by5.tv/images/broadcasts/19/cover.jpg", podcast.itunes_image
        assert_equal "productivity, communication, work, barriers, constraints, tools", podcast.itunes_keywords
        assert_equal "no", podcast.itunes_explicit
        assert_equal "5by5 Broadcasting", podcast.itunes_owner_name
        assert_equal "itunes@5by5.tv", podcast.itunes_owner_email
        assert_equal "Technology", podcast.itunes_category
        assert_equal "Software How-To", podcast.itunes_subcategories[0]
        assert_equal "Tech News", podcast.itunes_subcategories[1]
      end

      it "loads the metadata from feed url" do
        stub_request(:get, "http://feeds.feedburner.com/unprofessional-podcast")
          .to_return(:body => File.read('test/assets/unprofessional.xml'))

        podcast = Podcast.from_url("http://feeds.feedburner.com/unprofessional-podcast")
        assert_equal "Unprofessional", podcast.title
        assert_equal "http://muleradio.net/unprofessional", podcast.link
        # assert_equal Time.parse('2013-02-06 11:39 GMT').utc, podcast.pub_date

        description = "Lex and Dave have unprofessional conversations with interesting people."

        assert_equal description, podcast.description
        assert_equal "en", podcast.language

        # itunes info
        # assert_equal nil, podcast.itunes.new_feed_url
        # assert_equal nil, podcast.itunes_subtitle
        assert_equal "Mule Radio Syndicate", podcast.itunes_author
        assert_equal description, podcast.itunes_summary
        assert_equal "http://media.muleradio.net/images/shows/unprofessional/itunes.jpg", podcast.itunes_image
        assert_equal "lex friedman, dave wiskus, unprofessional, origin stories", podcast.itunes_keywords
        assert_equal "no", podcast.itunes_explicit
        assert_equal " Dave Wiskus  and Lex Friedman ", podcast.itunes_owner_name
        assert_equal "unprofessional@muleradio.net", podcast.itunes_owner_email
        assert_equal "Society & Culture", podcast.itunes_category
        assert_equal " Personal Journals", podcast.itunes_subcategories[0]
      end
    end

    # describe "podcast episode loading" do
    #   it "loads each episode from xml" do
    #   end
    # end
  end
end

