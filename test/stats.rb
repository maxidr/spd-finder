# encoding: UTF-8
require File.expand_path("helper", File.dirname(__FILE__))

scope do

  prepare do
    @stats = Stats.new
    @redis = Redis.new
    @redis.flushdb
  end

  setup do
    Stats.new
  end

  test 'add a new project' do |stats|
    info = { name: 'project_1' }
    stats.add_project(1, info)
    assert_equal info.to_json, @redis.get('projects:1')
  end

  test 'find project by id' do |stats|
    info = { name: 'project_11' }
    stats.add_project(11, info)
    assert_equal info, stats.find_project(11)
    assert !@stats.find_project(99)
  end

  test 'add project to axis' do |stats|
    stats.add_project_to_axis(1, 10)
    assert stats.is_project_in_axis? 1, 10
  end

  test 'find projects ids by axis' do |stats|
    stats.add_project_to_axis(1, 10)
    stats.add_project_to_axis(2, 10)
    stats.add_project_to_axis(2, 5)
    stats.add_project_to_axis(3, 5)
    assert_equal [1, 2], stats.find_projects_ids_by_axis(10)
    assert_equal [2, 3], stats.find_projects_ids_by_axis(5)
    assert_equal [1, 2, 3], stats.find_projects_ids_by_axis(5, 10)
  end

  test 'find projects by axis' do |stats|
    project_info = { name: 'project 1', identifier: 'p1' }
    stats.add_project(1, project_info)
    stats.add_project_to_axis(1, 10)
    assert_equal [ project_info ], stats.find_projects_by_axis(10)
  end

  test 'add axis and retrieve all the axis types' do |stats|
    axis_info = [ { id: 1, name: 'Funcional',
                  values: [
                    { id: 1, name: 'Software de gestión de datos | Gestión de base de datos' },
                    { id: 2, name: 'Software de gestión de datos | Modelado de base de datos' } ]
                } ]
    stats.add_axis_types(axis_info)
    list_of_axis = stats.all_axis_types
    assert_equal axis_info, list_of_axis
  end
end
