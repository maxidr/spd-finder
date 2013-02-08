# enconding: UTF-8

require 'json'

# This class interact with redis to persist the stats
# of any project and they relation with the 3 axis (functionality, 
# technology and activity).
#
# ### Planed structure:
#
#   *key:* "axis:NNNNN" (id of the axis)
#   Example: "axis:0017" represents: "Gestión de recursos corporativos | Administración de relaciones de clientes (CRM)"
#   
#   *value:* a bitmask with 1 when the project is included or 0 if not.  The project is determined by the bit position
#   in the bitmask.  
#
#   Example: Proyect 1 and 4 are included
#       000001010
#
class Stats

  def initialize(attrs = {})
    @redis = Redis.new(attrs)
  end

  def flush_database
    @redis.flushdb
  end

  # Add a new project to the stats
  # @param id [Fixnum or String] the id of the project
  # @param info [Hash] the values to persist
  def add_project(id, info)
    @redis.set project_key_of(id), info.to_json
  end

  # find project and return the text identifier
  # or false if not exists
  #
  # @return [Hash] with the project information
  def find_project(id)
    info = @redis.get project_key_of(id)
    JSON.parse(info, symbolize_names: true) if info
  end

  # Asociate project (id) with an axis (id)
  def add_project_to_axis(project_id, axis_id)
    @redis.setbit(axis_key_of(axis_id), project_id, 1)
  end

  def is_project_in_axis?(project_id, axis_id)
    @redis.getbit(axis_key_of(axis_id), project_id) == 1
  end

  # @return [Array of ids] the ids of the projects finded
  def find_projects_ids_by_axis(axis_ids)
    axis_keys = axis_ids.map { |axis_id| axis_key_of(axis_id) }
    bits = bit_operation_over_keys(axis_keys, 'OR')
    ids_from_bits(bits)
  end

  # @return [Array<Hash>] the list of projects in the axis (hash as list elements)
  def find_projects_by_axis(axis_ids)
    projects_ids = find_projects_ids_by_axis(axis_ids)
    return [] if projects_ids.empty?
    projects_keys = projects_ids.map { |p_id| project_key_of(p_id) }
    @redis.mget(projects_keys).map { |json_info| json_info ? JSON.parse(json_info, symbolize_names: true) : nil }
  end


  # Return all the axis types information
  # See #add_axis to show the hash format of any axis
  #
  # @return [Array] 
  def all_axis_types
    axis_types = @redis.get 'axis_types'
    JSON.parse(axis_types, symbolize_names: true)
  end

  # Expected an Array with a Hash as any element with the information 
  # of all the axis.
  #
  # Example
  #
  #   [  
  #     { id: 1, name: 'Funcional',                                                       # id and name of the axis type
  #       values: [                                                                       # values of the axis for this type
  #         { id: 1, name: 'Software de gestión de datos | Gestión de base de datos' },   
  #         { id: 2, name: 'Software de gestión de datos | Modelado de base de datos' }
  #       ]
  #     },
  #     { id: 2, name: 'Tecnico',                                                         # id and name of another axis type 
  #       values: [
  #         {......
  #       ]
  #     }
  #   ]
  #
  # @param axis_info [Array of Hash]
  #
  def add_axis_types(axis_info)
    @redis.set 'axis_types', axis_info.to_json
  end

  private

  def bit_operation_over_keys(keys_over_op, operator)
    # TODO: Cache the key and results
    key = 'search:result'
    bits = nil
    @redis.multi do
      @redis.bitop(operator, key, keys_over_op)
      bits = @redis.get(key)  # returns Future as a bits see (https://github.com/redis/redis-rb#futures)
    end
    bits.value
  end

  def project_key_of(id)
    "projects:#{id}"
  end

  def axis_key_of(id)
    "axis:#{id}"
  end

  def ids_from_bits(num)
    return [] if num.nil?
    ids = []
    bits = num.unpack('B*').first # "00010100101"
    0.upto(bits.size) do |bit_pos|
      ids << bit_pos if bits[bit_pos] == "1"
    end
    ids
  end

end
