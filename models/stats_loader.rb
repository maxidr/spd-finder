# This class have the responsibility of obtain the data from 
# the redmine database and populate the redis structure.
# In other words, is responsible for coordinate the RedmineDatabase
# and Stats messages.
#
class StatsLoader

  attr_reader :rdb, :stats

  # For build need the information for pass to RedmineDatabase constructor (as :db key)
  # and the information for the Stats class (as :redis key).
  # Or can load the RedmineDatabase instance (as :redmine_db) and the Stats instances
  # (as :stats).
  #
  # @param attrs [Hash] with the attributes for RedmineDatabase (:db) and Stats (:redis) constructors. Or
  # with the instances of RedmineDatabase (:redmine_db) and Stats (:stats)
  def initialize(attrs)
    @rdb = attrs[:redmine_db] || RedmineDatabase.new(attrs[:db])
    @stats = attrs[:stats] || Stats.new(attrs[:redis] || {})
  end

  def flush_redis
    @stats.flush_database
  end

  def load_projects
    @rdb.all_projects do |row|
      @stats.add_project(row[:id], slice(row, :name, :identifier, :description)) 
    end
  end

  def load_axis(*custom_fields_ids)
    all_axis = @rdb.all_axis(custom_fields_ids)
    @stats.add_axis_types all_axis
  end

  def load_project_axis_relations (*custom_fields_ids)
    @rdb.projects_axis_relations(custom_fields_ids) do |row|
      @stats.add_project_to_axis(row[:project_id], row[:axis_id])
    end
  end

  private

  # Slice hash by the keys
  # Example:
  #
  #   slice({ :a => 1, :b => 2, :c => 3 }, :a, :b) 
  #   # returns {:a => 1, :b => 2}
  #
  #   slice({ :a => 1, :b => 2, :c => 3 }, :a, :d) 
  #   # return {:a => 1 }
  # 
  def slice(hash, *keys)
    new_hash = {}
    keys.each do |k| 
      new_hash[k] = hash[k] if hash.has_key?(k) 
    end
    new_hash
  end

end
