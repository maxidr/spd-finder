# encoding: UTF-8
require File.expand_path("helper", File.dirname(__FILE__))
require 'sequel/adapters/mock'

def projects
  [
    { id: 1, name: 'project number 1', identifier: 'pj_1' },
    { id: 20, name: 'project number 20 new', identifier: 'nov_20' }
  ]
end

def project_in_axis
  [ 
    { project_id: 1,  axis_id: 1 },
    { project_id: 1,  axis_id: 32},
    { project_id: 1,  axis_id: 12},
    { project_id: 20, axis_id: 10},
    { project_id: 20, axis_id: 1 }
  ]
end

scope do 
  prepare do
    rdb = RedmineDatabase.new("mock://mysql2")
    stub(rdb.db).from(:projects) { projects }
    #stub(rdb.db).select.stub!.from.stub!.where { project_in_axis }
    stub(rdb).projects_axis_relations.returns do |ids, row_processor|
      project_in_axis.each do |row|
        row_processor.call(row)
      end
    end

    @loader = StatsLoader.new redmine_db: rdb
    @stats = Stats.new
    Redis.new.flushdb
  end

  test 'load_projects' do
    @loader.load_projects
    projects.each do |p|      
      assert_equal({ name: p[:name], identifier: p[:identifier] },  @stats.find_project(p[:id]))
    end
  end

  test 'load_project_axis_relations' do
    @loader.load_project_axis_relations(2,3,4)
    project_in_axis.each do |row|
      assert @stats.is_project_in_axis?(row[:project_id], row[:axis_id])
    end
  end

end
