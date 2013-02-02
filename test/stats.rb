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
    stats.add_project(1, 'project_1')
    assert @redis.get('projects:1') == 'project_1'
  end

  test 'find project by id' do |stats|
    stats.add_project(11, 'project_11')
    assert stats.find_project(11) == 'project_11'
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
end
