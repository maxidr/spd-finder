$:.unshift File.dirname(__FILE__)

require File.expand_path("settings", File.dirname(__FILE__))

require "cuba"
require "cuba/contrib"
#require "cuba/render"
require "mote"
require "redis"

Cuba.use Rack::MethodOverride
Cuba.use Rack::Session::Cookie, :secret => SecureRandom.hex(64)
Cuba.use Rack::Static,
    root: 'public',
    urls: ['/js', '/css', '/img']

#Cuba.plugin Cuba::Render
Cuba.plugin Cuba::Mote

Dir["./models/**/*.rb"].each  { |rb| require rb }

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
        
    #on param('q') do |q|
    #  projects = stats.find_projects_by_axis(q)
    #  res.write view('project_list', projects: projects.map { |p| convert_project_to_view_model(p) }) 
    #end
    
    on root do
      q = req.params['q'] || []
      projects = []
      unless q.empty?
        projects = projects_to_view_model stats.find_projects_by_axis(q)
      end
      puts "q: #{q}, class. #{q.class}"
      #res.write view('index', axis_types: stats.all_axis_types, q: q, projects: projects)
      render('index', axis_types: stats.all_axis_types, q: q, projects: projects)
    end

  end
end

