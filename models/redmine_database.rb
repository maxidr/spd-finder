require 'yaml'

class RedmineDatabase

  attr_reader :db

  def initialize(connection_info = nil)
    @db = Sequel.connect(connection_info)
    YAML::ENGINE.yamler= 'syck'
  end

  # Return an array with any element represent one project
  # Project content example:
  #     
  #     { id: 1, data: { name: 'project 1', identifier: 'proj_1', description: 'the description' } }
  #
  # Can use a block parameter that will be invoked on any row iteration.
  # The block must expected a row as parameter and the row contains:
  #   + id
  #   + name
  #   + identifier
  #
  #  Example:
  #
  #     all_projects do |row|
  #       puts row[:id]
  #       puts row[:name]
  #       puts row[:identifier]
  #       puts row[:description]
  #     end
  #
  #
  # @return [Array<Hash>]
  #
  def all_projects(&block)
    @db.from(:projects).map do |row|
      if block
        block.call(row)
      else
        { id: row[:id], data: { name: row[:name], identifier: row[:identifier], description: row[:description] } }
      end
    end
  end

  # Return an array with any value for the axis identified by the id parameter
  # Any element of the array contains:
  #   + axis_id
  #   + desc [description]
  #
  # The values are obtained from the table custom_fields for the custom_field_id
  # 
  # Can use a block as parameter to add funcionality in any row iteration.
  # Example:
  #
  #     all_axis(2) do |row|
  #       puts row[:axis_id]
  #       puts row[:desc]
  #     end
  #
  # @return [Array<Hash>]
  #
  def all_axis(custom_field_ids)
    all_axis = []
    all_values = @db.select(:id, :name, :possible_values).from(:custom_fields).where("id IN ?", custom_field_ids).all
    
    all_values.each do |row|
      axis_type = { id: row[:id], name: row[:name], values: [] }
      values = YAML.load(row[:possible_values])
      values.map do |desc|
        axis_type[:values] << parse_axis_description(desc)
      end
      all_axis << axis_type
    end
    all_axis
  end

  # Return the relations between projects and axis. 
  # The parameter limit the ids of the axis to find
  #
  # Can use a block as parameter to process in any row iteration.
  # Example:
  #
  #     projects_axis_relations(1,2) do |row|
  #       puts row[:project_id]
  #       puts row[:axis_id]
  #     end
  #
  # @return [Array<Hash>] where any element is a hash with projects_id and axis_id (example: { project_id: 1, axis_id: 10 })
  #
  def projects_axis_relations(custom_fields_ids, &row_processor)
    @db.select(:customized_id, :value)
      .from(:custom_values)
      .where("customized_type = 'Project' and custom_field_id IN ? and value != ''", custom_fields_ids)
      .map do |val|
        axis_info = parse_axis_description(val[:value])
        unless axis_info.nil?
          row = { project_id: val[:customized_id], axis_id: axis_info.fetch(:id) }
          row_processor ? row_processor.call(row) : row
        end
      end
  end

  private

  # Parse the string "010 GestiÃ³n de la informaciÃ³n | AdministraciÃ³n de registros"
  # into { id: 10, desc: "GestiÃ³n de la informaciÃ³n | AdministraciÃ³n de registros" }
  #
  # @return [Hash or nil] a hash with id and name as keys OR nil if the expected format is not "number space string"
  def parse_axis_description(axis_desc)
    matching = axis_desc.match(/(\d+\s)([\w*\W*\s*]*)/)
    return nil if matching.nil?
    { id: matching[1].to_i, name: matching[2] }
  end
  
end
