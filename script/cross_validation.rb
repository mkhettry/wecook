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
    fraction_extractor = FeatureExtractor::HasFractionFeatureExtractor.new(lines)
    #colon_char_extractor = FeatureExtractor::HasColonCharFeatureExtractor.new(lines)
    #sentence_count_extractor = FeatureExtractor::NumSentencesBucketingFeatureExtractor.new(lines)

    extractors = [word_feature_extractor, first_second_word_extractor, num_words_extractor, fraction_extractor]

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
  model_size=`ls -l training.txt.model`
  puts "Adding model file: #{model_size}"
end

def predict(test_files, logfile)
  model = LibLinearModel.new(:feature_id_file => 'feature_ids.txt', :model_file => 'training.txt.model')
  tot_bad_errors = 0
  tot_length = 0
  without_errors = 0
  test_files.each do |trn_file|
    cur_bad_errors, cur_length, errors = model.predict_trn(trn_file)
    if cur_bad_errors == 0
      without_errors += 1
    end
    tot_bad_errors += cur_bad_errors
    tot_length += cur_length
    errors.each do |e|
      logfile.puts("#{trn_file.filename}\t#{e}")
    end
  end
  #logfile.puts "{#{without_errors}/#{test_files.length}}"
  [tot_bad_errors, tot_length, without_errors]
end

def main(logfile)
  bad_errors = 0
  total_length = 0
  dir = Dir.new('config/training')
  logfile = File.new(logfile + ".log", 'w')
  files = dir.select {|f| f if f =~ /\.tr[su]$/}
  files.sort! {|a,b| a.hash <=> b.hash}
  for i in 0...files.length
    ranges = get_training_range(files.length, i)
    test_files = split_files(files, ranges)
    train
    cur_error, cur_length, no_errors = predict(test_files, logfile)
    puts "#{i}:{#{no_errors}/#{test_files.length}}(#{cur_error}/#{cur_length})=#{cur_error/Float(cur_length)}"
    bad_errors += cur_error
    total_length += cur_length
  end
  puts "(#{bad_errors}/#{total_length})=#{bad_errors/Float(total_length)}"
end


if __FILE__ == $PROGRAM_NAME
  if ARGV.length != 1
    puts "Usage: ruby create_lib_svm_data.rb identifier"
  else
    ll_home = `echo $LL_HOME`
    puts ll_home
    if ll_home.strip.empty?
      puts "You must set LL_HOME environment variable."
    else
      main($ARGV[0])
    end
  end
end
