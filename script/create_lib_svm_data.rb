#prepares the data in a format that liblinear/libsvm can understand

LABEL_ID_MAPPING = {"PR" => "0", "IN" => "1", "OT" => "2", "FO" => "3", "NO" => 4, "TA" => 5}
MAX_COUNT_PER_CLASS = 300

class WordFeatureExtractor

  def initialize(training_rows)
    #TODO nothing for now. But, we can filter the words initially - maybe freq threshold
  end

  def extract_features(training_row)
    features = []
    training_row.description.split(/ +/).each do |word|
      features << ["word_" + word, 1]
    end
    features
  end
end

class LengthFeatureExtractor

  def initialize(training_rows)
    max_element = training_rows.max {|a,b| a.description.length <=> b.description.length}
    @max_description_length = Float(max_element.description.length)
  end

  def extract_features(training_row)
    value = Float(training_row.description.length/@max_description_length)
    feature = ["length", value]
    puts "length feature: #{feature}"
    [feature]
  end
end


class TrainingRow

  attr_reader :description, :class_label

  def initialize(description, class_label)
    @description = description.strip()
    @class_label = class_label.strip()
  end
end

class LibLinearFeatures

  @@feature_id_map = {}
  attr_accessor :class_id

  def initialize(class_id)
    @feature_map = {}
    @class_id = class_id
  end

  def add_feature_value(feature_id, feature_value)
    @feature_map[feature_id] = feature_value
  end

  def to_s
    outString = @class_id + " "
    outString << get_sorted_features()
    outString.strip()
  end

  def get_sorted_features
    sorted_keys = @feature_map.keys.sort
    sorted_features = ""
    sorted_keys.each{|k| sorted_features << "#{k}:#{@feature_map[k]} "}
    sorted_features
  end

  def LibLinearFeatures.to_lib_linear_features(feature_extractors, training_row)
    lib_linear_features = LibLinearFeatures.new(LABEL_ID_MAPPING[training_row.class_label])

    feature_extractors.each do |current_feature_extractor|
      current_features = current_feature_extractor.extract_features(training_row)
      current_features.each do |k|
        lib_linear_features.add_feature_value(LibLinearFeatures.get_feature_id(k[0]),k[1])
      end
    end
    lib_linear_features
  end

  def LibLinearFeatures.get_feature_id(feature_name)
    unless @@feature_id_map.has_key?(feature_name)
      @@feature_id_map[feature_name] = @@feature_id_map.length + 1
    end
    @@feature_id_map[feature_name]
  end
end


def main
  ## Read training rows ##
  files = get_filenames(ARGV[0])
  training_rows = []
  files.each do |file|
    training_rows.concat(get_training_rows_from_file(ARGV[0] + file))
  end
  puts "Size of training rows: #{training_rows.length}"

  ## extract features and convert to lib-linear features ##
  word_feature_extractor = WordFeatureExtractor.new(training_rows)
  length_feature_extractor = LengthFeatureExtractor.new(training_rows)

  liblinear_features_list = training_rows.collect do |training_row|
    LibLinearFeatures.to_lib_linear_features([word_feature_extractor,length_feature_extractor], training_row)
  end
  puts "Size of liblinear-features-list: #{liblinear_features_list.length}"

  ## Write train/test ##
  output_train = File.new(ARGV[1] + "training_data.libsvm", "w")
  output_test = File.new(ARGV[1] + "test_data.libsvm", "w")
  write_outputs(output_train, output_test, liblinear_features_list)


end



def write_outputs(output_train, output_test, liblinear_features)
  class_counts = {"0" => 0, "1" => 0, "2" => 0}
  liblinear_features.each do |feature|
    if class_counts.has_key?feature.class_id
      #check how much has gone to train
      if (class_counts[feature.class_id] > MAX_COUNT_PER_CLASS)
        output_test.puts(feature.to_s)
      else
        output_train.puts(feature.to_s)
      end

      class_counts[feature.class_id] += 1
    end
  end
end

def get_training_rows_from_file(filename)
  training_rows = []
  file = File.new(filename)
  file.each_line do |line|
    row = line.split("\t")
    unless row.length != 2
      training_rows << TrainingRow.new(row[1],row[0])
    end
  end
  training_rows
end

def get_filenames(dir)
  filenames = []
  Dir.foreach(dir) do |filename|
    next unless filename =~ /\.trn/
    filenames << filename
  end
  filenames
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.length != 2
    puts "Usage: ruby create_lib_svm_data.rb.rb <training-data-dir> <output-dir>"
  else
    main()
  end
end
