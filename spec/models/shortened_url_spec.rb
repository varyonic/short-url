require 'spec_helper'

describe ShortenedUrl do
  before (:each) do
    ShortenedUrl.connection.execute(
      'ALTER SEQUENCE shortened_urls_id_seq RESTART WITH 1'
      )
  end

  describe '#map' do
    it "shortens long URLs" do
      ShortenedUrl.map("http://www.foo.com").should == "http://va.ry/1z"
    end
    it "lengthens short URLs" do
      ShortenedUrl.create(full_url: "http://www.foo.com")
      ShortenedUrl.map("http://va.ry/1z").should == "http://www.foo.com"
    end
  end

  describe '#short_uri' do
    it "identifies whether a URL has been shortened" do
      ShortenedUrl.short_uri?("http://www.foo.com").should be_false
      ShortenedUrl.short_uri?("http://va.ry/1z").should be_true
    end
  end

  describe '#lengthen' do
    it "converts a short URL to a long" do
      ShortenedUrl.create(full_url: "http://www.foo.com")
      ShortenedUrl.lengthen("http://va.ry/1z").should == "http://www.foo.com"
    end
  end

  describe '#shorten' do
    it "converts a long URL to a short" do
      ShortenedUrl.shorten("http://www.foo.com").should == "http://va.ry/1z"
      ShortenedUrl.shorten("http://www.bar.com").should == "http://va.ry/2y"
    end

    it "reuses a short URL if it already exists" do
      ShortenedUrl.shorten("http://www.foo.com").should == "http://va.ry/1z"
      ShortenedUrl.shorten("http://www.foo.com").should == "http://va.ry/1z"
    end
  end

  describe '#encode' do
    it "converts a number to an encoded string" do
      ShortenedUrl.encode(0,ShortenedUrl::BASE10).should == '00'
      ShortenedUrl.encode(9,ShortenedUrl::BASE10).should == '91'
      ShortenedUrl.encode(10,ShortenedUrl::BASE10).should == '109'
      ShortenedUrl.encode(11,ShortenedUrl::BASE10).should == '118'

      ShortenedUrl.encode(11,ShortenedUrl::BASE16).should == 'b5'
      ShortenedUrl.encode(255,ShortenedUrl::BASE16).should == 'ff2'

      ShortenedUrl.encode(10,ShortenedUrl::BASE36).should == 'aq'
      ShortenedUrl.encode(35,ShortenedUrl::BASE36).should == 'z1'
      ShortenedUrl.encode(36,ShortenedUrl::BASE36).should == '10z'
      ShortenedUrl.encode(37,ShortenedUrl::BASE36).should == '11y'
      ShortenedUrl.encode(12341235,ShortenedUrl::BASE36).should == "7cik3c"
    end
  end

  describe '#decode' do
    it "converts an encoded string into a number" do
      ShortenedUrl.decode('ff2',ShortenedUrl::BASE16).should == 255
      ShortenedUrl.decode("7CIK3C",ShortenedUrl::BASE36).should == 12341235
      ShortenedUrl.decode("1oz",ShortenedUrl::BASE35).should == 35
    end

    it "throws an exception if the checkdigit is incorrect" do
      expect {
        ShortenedUrl.decode("1oy",ShortenedUrl::BASE35).should == 35
      }.to raise_error ShortenedUrl::NotFound
    end
  end

  describe '#checkdigit' do
    it "computes a checkdigit for a number in a given base" do
      ShortenedUrl.checkdigit('99',ShortenedUrl::BASE10).should == '2'
    end
  end
end
