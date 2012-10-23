require 'spec_helper'

describe ShortenedUrlsController do
  before (:each) do
    ShortenedUrl.connection.execute(
      'ALTER SEQUENCE shortened_urls_id_seq RESTART WITH 1'
      )
  end

  describe "#map" do
    it "converts long URLs to short" do
      get 'http://localhost:3000/http://www.example.com/'
      response.body.should match /http:\/\/va.ry\/1$/
    end

    it "converts short URLs to long" do
      get 'http://localhost:3000/http://www.example.com/'
      get 'http://localhost:3000/http://va.ry/1'
      response.body.should match /http:\/\/www.example.com$/
    end
  end
end
