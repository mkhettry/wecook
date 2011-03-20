class Feature
  include Comparable

  @@name_id_map = {}
  @@max_id = 1

  attr_accessor :feature_id, :name, :value

  def initialize(name, value = 1)
    @name = name
    @value = value
    @feature_id = Feature.get_feature_id(name)
  end

  def self.get_feature_id(name)
    if not @@name_id_map.has_key? name
      @@name_id_map[name] = @@max_id
      @@max_id = @@max_id + 1
    end
    @@name_id_map[name]
  end

  def to_liblinear_form
    @feature_id.to_s + ":" + @value.to_s
  end

  def <=>(other)
    @feature_id <=> other.feature_id
  end

  def self.write_feature_ids_to_file(outfile)
    @@name_id_map.sort_by{|k,v| v}.each do |pair|
      outfile.puts(pair[0])
    end
  end

  def self.from_liblinear_form(s)
    parts = s.split(":")
    feature = Feature.new(nil, Float(parts[1]))
    feature.feature_id = Integer(parts[0])
    feature
  end

end