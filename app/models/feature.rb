class Feature
  include Comparable

  @@name_id_map = {}
  @@max_id = 1

  attr_accessor :feature_id, :name, :value, :categorical

  def initialize(name, *value)
    @name = name
    if value.length == 0
      @value = 1
      @categorical = true
    else
      @value = value[0]
      @categorical = false
    end
    @feature_id = Feature.get_feature_id(name)
  end

  def self.get_feature_id(name)
    if not @@name_id_map.has_key? name
      @@name_id_map[name] = @@max_id
      @@max_id = @@max_id + 1
    end
    @@name_id_map[name]
  end

  def self.write_feature_vector(fv)
    s = ""
    fv.each do |f|
      s << f.to_liblinear_form
      s << " "
    end
    s
  end

  def to_liblinear_form
    @feature_id.to_s + ":" + @value.to_s
  end

  def <=>(other)
    @feature_id <=> other.feature_id
  end

  def eql?(object)
    [@name, @value] == [object.name, object.value]
  end

  def hash
    [@name, @value].hash
  end

  def to_s
    "#{feature_id}:#{name}=#{value}"
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