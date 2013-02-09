$:.unshift File.dirname(__FILE__)

require File.expand_path("settings", File.dirname(__FILE__))

require "cuba"
require "cuba/contrib"
#require "cuba/render"
require "mote"
require "redis"
require "rake"

Cuba.use Rack::MethodOverride
Cuba.use Rack::Session::Cookie, :secret => SecureRandom.hex(64)
Cuba.use Rack::Static,
    root: 'public',
    urls: ['/js', '/css', '/img']

#Cuba.plugin Cuba::Render
Cuba.plugin Cuba::Mote

Dir["./models/**/*.rb"].each  { |rb| require rb }
Dir["./lib/**/*.rb"].each { |rb| require rb }

Cuba.plugin ViewHelper

def stats
  @stats ||= Stats.new(url: Settings::REDIS_URL)
end

def projects_to_view_model(projects)
  projects.map do |project|
    {
      name: project[:name],
      link: "#{Settings::REDMINE_URL}/projects/#{project[:identifier]}",
      description: project[:description]
    }
  end
end

Cuba.define do
  on get do
        
    on root do
      q = req.params['q'] || []
      projects = []
      unless q.empty?
        projects = projects_to_view_model stats.find_projects_by_axis(q)
      end
      render('index', axis_types: stats.all_axis_types, q: q, projects: projects)
    end
    
    on 'reload', param('ids') do |ids|
      ENV["CUSTOM_FIELD_IDS"] = ids
      rake = Rake::Application.new
      Rake.application = rake
      rake.init
      rake.load_rakefile
      rake[:import].invoke
      res.write "reloaded using ids: #{ids}"
    end

  end
end

