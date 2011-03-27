TEST_PERCENTAGE = 80

# 100 files
# idx = 75
# 75..99, 0..54
def get_training_range(total_size, idx)
  num_files = (total_size * TEST_PERCENTAGE) / 100
  if (idx + num_files <= total_size)
    [idx...(idx + num_files)]
  else
    [idx...total_size, 0...num_files - (total_size - idx)]
  end
end

def split_files(files, ranges)
    test_files = []
    training_file = File.new('training.txt', 'w')
    lines = []
    for idx in 0...files.length
      tf = TrainingFile.new('config/training/' + files[idx])
      if not in_range(ranges, idx)
        test_files << tf
        next
      end
      lines += tf.get_lines
    end

    word_feature_extractor = FeatureExtractor::WordFeatureExtractor.new(lines)
    #length_feature_extractor = FeatureExtractor::LengthFeatureExtractor.new(lines)
    first_second_word_extractor = FeatureExtractor::FirstAndSecondWordFeatureExtractor.new(lines)
    num_words_extractor = FeatureExtractor::WordBucketingFeatureExtractor.new(lines)
    extractors = [word_feature_extractor, first_second_word_extractor, num_words_extractor]

    lines.each do |line|
      fv = []
      extractors.each do |e|
        fv += e.extract_features(line.text)
      end
      fv.sort!
      class_id = LibLinearModel.from_class_str_to_ids(line.class)
      feature_vector_str = Feature.write_feature_vector(fv)
      training_file.puts("#{class_id} #{feature_vector_str}")
    end


    feature_id_file = File.new('feature_ids.txt', 'w')
    feature_id_file.puts(extractors.collect{|extractor| extractor.class}.join(","))
    Feature.write_feature_ids_to_file(feature_id_file)
    return test_files
end

def in_range(ranges, idx)
  ranges.each do |range|
    if (range.include? idx)
      return true
    end
  end
  false
end

def train
  `$LL_HOME/train -s 0 training.txt`
end

def predict(test_files)
  model = LibLinearModel.new(:feature_id_file => 'feature_ids.txt', :model_file => 'training.txt.model')
  tot_bad_errors = 0
  tot_length = 0
  without_errors = 0
  test_files.each do |trn_file|
    cur_bad_errors, cur_length = model.predict_trn(trn_file)
    if cur_bad_errors == 0
      without_errors += 1
    end
    tot_bad_errors += cur_bad_errors
    tot_length += cur_length
  end
  puts "{#{without_errors}/#{test_files.length}}"
  [tot_bad_errors, tot_length]
end

def main
  bad_errors = 0
  total_length = 0
  dir = Dir.new('config/training')
  files = dir.select {|f| f if f =~ /\.trn$/}.sort
  for i in 0...files.length
    ranges = get_training_range(files.length, i)
    test_files = split_files(files, ranges)
    train
    cur_error, cur_length = predict(test_files)
    puts "(#{cur_error}/#{cur_length})=#{cur_error/Float(cur_length)}"
    bad_errors += cur_error
    total_length += cur_length
  end
  puts "(#{bad_errors}/#{total_length})=#{bad_errors/Float(total_length)}"
end


if __FILE__ == $PROGRAM_NAME
  if ARGV.length != 0
    puts "Usage: ruby create_lib_svm_data.rb"
  else
    main()
  end
end
