# enconding: UTF-8
#
# This class interact with redis to persist the stats
# of any project and they relation with the 3 axis (functionality, 
# technology and activity).
#
# ### Planed structure:
#
#   *key:* NNNNN (id of the axis)
#   Example: 0017 represents: "Gestión de recursos corporativos | Administración de relaciones de clientes (CRM)"
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
  def add_project(id, text_identifier)
    @redis.set project_key(id), text_identifier
  end

  # find project and return the text identifier
  # or false if not exists
  def find_project(id)
    @redis.get project_key(id)
  end

  def add_project_to_axis(project_id, axis_id)
    @redis.setbit(axis_key(axis_id), project_id, 1)
  end

  def is_project_in_axis?(project_id, axis_id)
    @redis.getbit(axis_key(axis_id), project_id) == 1
  end

  private

  def project_key(id)
    "projects:#{id}"
  end

  def axis_key(id)
    "axis:#{id}"
  end

end
