#ENV["REDIS_URL"] ||= "redis://127.0.0.1:6379/13"

require File.expand_path("../app", File.dirname(__FILE__))
#require "cuba/test"
require 'redis'

#prepare do
#  Capybara.reset!
#  Ohm.flush
#end
#
#class Cutest::Scope
#  def session
#    Capybara.current_session.driver.request.env["rack.session"]
#  end
#end

