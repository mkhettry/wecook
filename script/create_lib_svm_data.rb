#prepares the data in a format that liblinear/libsvm can understand
# Can we move this to a class?
LABEL_ID_MAPPING = {"PR" => 0, "IN" => 1, "OT" => 2, "FO" => 3, "NO" => 4, "TA" => 5}
IGNORE_WORDS = {"a" => 1, "an" => 1, "the" => 1, "of" => 1, "and" => 1, "to" => 1}

class TrainingRow

  attr_reader :description, :class_label

  def initialize(description, class_label)
    @description = description.strip()
    @class_label = class_label.strip()
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
  word_feature_extractor = FeatureExtractor::WordFeatureExtractor.new(training_rows)
  length_feature_extractor = FeatureExtractor::LengthFeatureExtractor.new(training_rows)
  first_second_word_extractor = FeatureExtractor::FirstAndSecondWordFeatureExtractor.new(training_rows)
  extractors = [word_feature_extractor, first_second_word_extractor]

  feature_matrix = []
  class_labels = []

  training_rows.each do |row|
    next if row.description.strip.empty? or not LABEL_ID_MAPPING.has_key?(row.class_label)
    feature_vector = []
    class_labels << LABEL_ID_MAPPING[row.class_label]
    extractors.each do |extractor|
      feature_vector += extractor.extract_features(row.description)
    end
    feature_vector.sort!
    feature_matrix << feature_vector
  end

  #puts liblinear_features_list.to_s
  puts "Size of liblinear-features-list: #{feature_matrix.length}"

  ## Write train/test ##
  output_train = File.new("training_data.libsvm", "w")
  output_test = File.new("test_data.libsvm", "w")
  output_test_description = File.new("test_data_description.libsvm","w")
  write_outputs(output_train,output_test, output_test_description, feature_matrix, class_labels, training_rows)
  output_test.close
  output_train.close
  output_test_description.close

  feature_id_file = File.new("feature_ids.libsvm", 'w')
  feature_id_file.puts(extractors.collect{|extractor| extractor.class}.join(","))
  Feature.write_feature_ids_to_file(feature_id_file)
end


def write_feature_vector(fv)
  s = ""
  fv.each do |f|
    s << f.to_liblinear_form
    s << " "
  end
  s
end

# [feature, feature]
def write_outputs(output_train, output_test, output_test_description, feature_matrix, class_labels, training_rows)
  for i in 0...feature_matrix.length
    random = rand(100)
    feature_vector = feature_matrix[i]
    if (random > 79)
      output_test.puts(class_labels[i].to_s + " " + write_feature_vector(feature_vector))
      output_test_description.puts(class_labels[i].to_s + "\t" + training_rows[i].description)
    else
      output_train.puts(class_labels[i].to_s + " " + write_feature_vector(feature_vector))
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
  if ARGV.length != 1
    puts "Usage: ruby create_lib_svm_data.rb <training-data-dir>"
  else
    main()
  end
end
