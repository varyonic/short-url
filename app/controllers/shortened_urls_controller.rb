class ShortenedUrlsController < ApplicationController
  def map
    render text: ShortenedUrl.map(params[:url])
  end
end
