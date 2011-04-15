class ModelBuilder
  @@feature_selector = FeatureSelector.new

  def self.feature_selector
    @@feature_selector
  end

  def self.build(opt)
    if opt[:dir]
      dirname = opt[:dir]
      dir = Dir.new(dirname)
      files = dir.select {|f| f if f =~ /\.tr[su]$/}
      files.map! { |f| TrainingFile.new(dirname + "/" + f)}
    else
      files = opt[:files]
    end

    puts files[0]
    build_model_from_training_files(files)
  end

  def self.build_model_from_training_files(train_files)

      lines = []
      train_files.each do |f|
        lines += f.get_lines
      end

      training_file = File.new('training.txt', 'w')

      word_feature_extractor = FeatureExtractor::WordFeatureExtractor.new(lines)
      #length_feature_extractor = FeatureExtractor::LengthFeatureExtractor.new(lines)
      first_second_word_extractor = FeatureExtractor::FirstAndSecondWordFeatureExtractor.new(lines)
      num_words_extractor = FeatureExtractor::WordBucketingFeatureExtractor.new(lines)
      fraction_extractor = FeatureExtractor::HasFractionFeatureExtractor.new(lines)
      pos_extractor = FeatureExtractor::PosFeatureExtractor.new(lines)
      #has_number_extractor = FeatureExtractor::HasNumberFeatureExtractor.new(lines)
      #colon_char_extractor = FeatureExtractor::HasColonCharFeatureExtractor.new(lines)
      #sentence_count_extractor = FeatureExtractor::NumSentencesBucketingFeatureExtractor.new(lines)

      extractors = [word_feature_extractor, pos_extractor, first_second_word_extractor, num_words_extractor, fraction_extractor]

      train_data = []
      lines.each do |line|
        fv = []
        extractors.each do |e|
          cur_fv = e.extract_features(line.text)
          fv += cur_fv unless cur_fv.nil?
        end
        class_id = LibLinearModel.from_class_str_to_ids(line.class)
        @@feature_selector.update(LibLinearModel.from_class_str(line.class), fv)
        train_data << [class_id, fv]
      end

      train_data.each do |data|
        class_id = data[0]
        fv = @@feature_selector.filter(data[1])
        fv.sort!
        feature_vector_str = Feature.write_feature_vector(fv)
        training_file.puts("#{class_id} #{feature_vector_str}")
      end

      feature_id_file = File.new('feature_ids.txt', 'w')
      feature_id_file.puts(extractors.collect{|extractor| extractor.class}.join(","))
      Feature.write_feature_ids_to_file(feature_id_file)
      train
  end

  def self.train()
    `$LL_HOME/train -s 0 training.txt`
    model_size=`ls -l training.txt.model`
    #puts "Adding model file: #{model_size}"
  end


end