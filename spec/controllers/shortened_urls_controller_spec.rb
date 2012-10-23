require 'spec_helper'

describe ShortenedUrlsController do
  before (:each) do
    ShortenedUrl.connection.execute(
      'ALTER SEQUENCE shortened_urls_id_seq RESTART WITH 1'
      )
  end

  describe "#map" do
    it "converts long URLs to short" do
      get :map, url: 'http://www.example.com/'
      response.body.should match /http:\/\/va.ry\/1z$/
    end

    it "converts short URLs to long" do
      ShortenedUrl.create(full_url: "http://www.foo.com")
      get :map, url: 'http://va.ry/1z'
      response.body.should match /http:\/\/www.foo.com$/
    end
  end
end
