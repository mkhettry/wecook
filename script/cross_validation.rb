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

def train(files, ranges)
    #TODO, shouldn't pass in NIL
    word_feature_extractor = FeatureExtractor::WordFeatureExtractor.new(nil)
    #length_feature_extractor = FeatureExtractor::LengthFeatureExtractor.new(training_rows)
    first_second_word_extractor = FeatureExtractor::FirstAndSecondWordFeatureExtractor.new(nil)
    extractors = [word_feature_extractor, first_second_word_extractor]

    training_file = File.new('training.txt', 'w')
    test_file = File.new('test.txt', 'w')

    for idx in 0...files.length
      tf = TrainingFile.new('config/training/' + files[idx])
      tf.get_lines.each do |training_row|
        fv = []
        extractors.each do |e|
          fv += e.extract_features(training_row.text)
        end
        fv.sort!
        class_id = LibLinearModel.from_class_str_to_ids(training_row.class)
        feature_vector_str = Feature.write_feature_vector(fv)
        if (in_range(ranges, idx))
          training_file.puts("#{class_id} #{feature_vector_str}")
        else
          test_file.puts("#{class_id} #{feature_vector_str}")
        end
      end
    end

    Feature.write_feature_ids_to_file(File.new('feature_ids.txt', 'w'))

end

def in_range(ranges, idx)
  ranges.each do |range|
    if (range.include? idx)
      return true
    end
  end
  false
end

def main
  dir = Dir.new('config/training')
  files = dir.select {|f| f if f =~ /\.trn$/}.sort
  ranges = get_training_range(files.length, Integer(ARGV[0]))
  train(files, ranges)
end


if __FILE__ == $PROGRAM_NAME
  if ARGV.length != 1
    puts "Usage: ruby create_lib_svm_data.rb <train_start_index>"
  else
    main()
  end
end
