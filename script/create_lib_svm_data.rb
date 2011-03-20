#prepares the data in a format that liblinear/libsvm can understand
LABEL_ID_MAPPING = {"PR" => 0, "IN" => 1, "OT" => 2, "FO" => 3, "NO" => 4, "TA" => 5}
IGNORE_WORDS = {"a" => 1, "an" => 1, "the" => 1, "of" => 1, "and" => 1, "to" => 1}

class WordFeatureExtractor

  def initialize(training_rows)
    #TODO nothing for now. But, we can filter the words initially - maybe freq threshold
  end

  def extract_features(training_row)
    features = []
    training_row.get_words().each do |word|
      features << Feature.new("word_" + word)
    end
    features
  end
end

class FirstAndSecondWordFeatureExtractor

  def initialize(training_rows)
    #NOTHING
  end

  def extract_features(training_row)
    features = []
    words = training_row.get_words
    features << Feature.new("first_word_" + words[0]) if words.length > 0
    features << Feature.new("second_word_" + words[1]) if words.length > 1
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
    feature = Feature.new("length", value)
    [feature]
  end
end


class TrainingRow

  attr_reader :description, :class_label

  def initialize(description, class_label)
    @description = description.strip()
    @class_label = class_label.strip()
  end

def get_words()
    #words = doc.split(/\W+/)
    #words = doc.split
    #split on white space and "-"
    words = @description.split(/[\s-]/)

    words = words.select {|w| w.strip.length > 0 and IGNORE_WORDS[w].nil?}
    words.collect! { |w| w}
    new_words = []
    words.each do |w|
      if w =~ /(\d+)([a-zA-Z]+)$/
        new_words << $1
        new_words << $2
      else
        new_words << w
      end
    end
    new_words.uniq
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
  first_second_word_extractor = FirstAndSecondWordFeatureExtractor.new(training_rows)
  extractors = [word_feature_extractor, first_second_word_extractor]

  feature_matrix = []
  class_labels = []

  training_rows.each do |row|
    next if row.description.strip.empty?
    feature_vector = []
    class_labels << LABEL_ID_MAPPING[row.class_label]
    extractors.each do |extractor|
      feature_vector += extractor.extract_features(row)
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

  Feature.write_feature_ids_to_file(File.new("feature_ids.libsvm", 'w'))
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
