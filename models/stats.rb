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

  # Add a new project to the stats
  # @param id [Fixnum or String] the id of the project
  # @param info [Hash] the values to persist
  def add_project(id, info)
    @redis.set project_key(id), info.to_json
  end

  # find project and return the text identifier
  # or false if not exists
  #
  # @return [Hash] with the project information
  def find_project(id)
    info = @redis.get project_key(id)
    JSON.parse(info, symbolize_names: true) if info
  end

  # Asociate project (id) with an axis (id)
  def add_project_to_axis(project_id, axis_id)
    @redis.setbit(axis_key(axis_id), project_id, 1)
  end

  def is_project_in_axis?(project_id, axis_id)
    @redis.getbit(axis_key(axis_id), project_id) == 1
  end

  # @return [Array of ids] the ids of the projects finded
  def find_projects_ids_by_axis(*axis)
    key = "find"
    axis_ids = []
    axis.each do |axis_id|
      key << ":" << axis_id
      axis_ids << axis_key(axis_id)
    end
    # TODO: Cache the key and results
    @redis.bitop('OR', key, axis_ids)
    ids_from_bits(@redis.get(key))
  end

  private

  def project_key(id)
    "projects:#{id}"
  end

  def axis_key(id)
    "axis:#{id}"
  end

  def ids_from_bits(num)
    ids = []
    bits = num.unpack('B*').first # "00010100101"
    0.upto(bits.size) do |bit_pos|
      ids << bit_pos if bits[bit_pos] == "1"
    end
    ids
  end

end
