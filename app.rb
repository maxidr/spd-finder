$:.unshift File.dirname(__FILE__)

#require File.expand_path("settings", File.dirname(__FILE__))

require "cuba"

Cuba.use Rack::MethodOverride
Cuba.use Rack::Session::Cookie, :secret => SecureRandom.hex(64)
Cuba.use Rack::Static,
    root: 'public',
    urls: ['/js', '/css', '/img']

Dir["./models/**/*.rb"].each  { |rb| require rb }

Cuba.define do
  on root do 
    res.write 'hello'
  end
end

