# encoding: UTF-8
require File.expand_path("helper", File.dirname(__FILE__))
require 'sequel/adapters/mock'
require 'yaml'

def projects_db_format
    [ 
      { id: 1, name: 'test 1', identifier: 'test_1', description: 'the description 1'  },
      { id: 2, name: 'test 2', identifier: 'test_2', description: 'the description 2'  },
    ]
end

def projects_method_format
  projects_db_format.map { |row| convert_row_to_expected_hash(row) }
end

def convert_row_to_expected_hash(row)
    { id: row[:id], 
      data: { name: row[:name], identifier: row[:identifier], description: row[:description] } 
    }
end

scope do
  prepare do
    any_instance_of(Sequel::Mock::Database) do |db|
      stub(db).from(:projects) { projects_db_format } 

      stub(db).select(:id, :name, :possible_values).stub!.from.stub!.where.stub!.all do
        [ 
          { id: 1,
            name: 'Funcional',
            possible_values: [
              '010 GestiÃ³n de la informaciÃ³n | AdministraciÃ³n de registros',
              '011 GestiÃ³n de la informaciÃ³n | GestiÃ³n documental'
            ].to_yaml 
          }
        ]
      end

      stub(db).select(:customized_id, :value).stub!.from.stub!.where do
        [ { customized_id: 1, value: "0010 Tipo de proyecto | subtipo de proyecto" } ]
      end
    end

    @redmine = RedmineDatabase.new("mock://mysql2")
  end

  test 'all_axis' do
    expect = [
      { id: 1, name: 'Funcional', 
        values: [
          { axis_id: 10, desc: 'GestiÃ³n de la informaciÃ³n | AdministraciÃ³n de registros' },
          { axis_id: 11, desc: 'GestiÃ³n de la informaciÃ³n | GestiÃ³n documental' }
        ]}
    ]
    assert_equal expect, @redmine.all_axis(2)
  end

  test 'all_axis with block as parameter' do
    @redmine.all_axis(2, 3, 4) do |axis|
      assert_equal({ axis_id: axis[:axis_id], desc: axis[:desc] }, axis)
    end
  end

  test 'all_project' do
    assert_equal projects_method_format, @redmine.all_projects
  end

  test 'all_proyect with block as parameter' do
    expected = {}
    @redmine.all_projects do |row|
      expected = { id: row[:id], name: row[:name], identifier: row[:identifier], description: row[:description] }
      assert_equal expected, row
    end
  end

  test 'projects_axis_relations' do
    expect = [ { project_id: 1, axis_id: 10 } ]
    assert_equal expect, @redmine.projects_axis_relations(2,3)
  end

  test 'projects_axis_relations with block as parameter' do
    @redmine.projects_axis_relations(2, 3) do |row|
      assert_equal({ project_id: row[:project_id], axis_id: row[:axis_id] }, row)
    end
  end
end
