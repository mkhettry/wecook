class LibLinearFeatureVector
  @@feature_id_map = {}
  attr_accessor :class_id, :description

  def initialize(class_id)
    @feature_map = {}
    @class_id = Integer(class_id)
    @description = ""
  end

  def add_feature_value(feature_id, feature_value)
    @feature_map[Integer(feature_id)] = Float(feature_value)
  end

  def get_features
    features = []
    @feature_map.keys.each do |key|
      features << [key, @feature_map[key]]
    end
    features
  end

  def to_s
    outString = @class_id.to_s + " "
    outString << get_sorted_features()
    outString.strip()
  end

  def get_sorted_features
    sorted_keys = @feature_map.keys.sort
    sorted_features = ""
    sorted_keys.each{|k| sorted_features << "#{k}:#{@feature_map[k]} "}
    sorted_features
  end

  # list(fe)
  # class fe
  #    to_feature_vector(training_row)
  #
  def LibLinearFeatureVector.to_lib_linear_feature_vector(feature_extractors, training_row)
    feature_vector = LibLinearFeatureVector.new(LABEL_ID_MAPPING[training_row.class_label])

    feature_extractors.each do |current_feature_extractor|
      current_features = current_feature_extractor.extract_features(training_row)
      current_features.each do |k|
        feature_vector.add_feature_value(LibLinearFeatureVector.get_feature_id(k[0]),k[1])
      end
    end
    feature_vector.description = training_row.description
    feature_vector
  end

  def LibLinearFeatureVector.get_feature_id(feature_name)
    unless @@feature_id_map.has_key?(feature_name)
      @@feature_id_map[feature_name] = @@feature_id_map.length + 1
    end
    @@feature_id_map[feature_name]
  end

  def self.write_feature_ids_to_file(filename)
    outfile = File.new(filename, "w")
    @@feature_id_map.sort_by{|k,v| v}.each do |pair|
      outfile.puts(pair[0])
    end
    outfile.close
  end
end