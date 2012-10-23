ShortUrl::Application.routes.draw do
  match ':url' => 'shortened_urls#map', :constraints => {:url => /.*/}
end
