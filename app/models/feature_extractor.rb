class FeatureExtractor
  IGNORE_WORDS = {"a" => 1, "an" => 1, "the" => 1, "of" => 1, "and" => 1, "to" => 1}

  def self.get_words(line)
    #words = doc.split(/\W+/)
    #words = doc.split
    #split on white space and "-"

    # remove the first word if it is of the form 2.
    line = line.gsub(/^\d+\.\s/, '')

    words = line.downcase.split(/[,\s\(\)-]+/)

    words = words.select {|w| w.strip.length > 0 and IGNORE_WORDS[w].nil?}
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

  class HasFractionFeatureExtractor
    def initialize(lines)
    end

    def extract_features(line)
      words = FeatureExtractor.get_words(line)
      words.each do |word|
        return [Feature.new("fraction")] if word =~ /^\d+\/\d+$/
      end
      []
    end
  end

  class WordBucketingFeatureExtractor

    def initialize(lines)
    end

    def extract_features(line)

      length = FeatureExtractor.get_words(line).length
      case
        when length <=5
          return [Feature.new("word_length_5")]
        when length <=10
          return [Feature.new("word_length_10")]
        when length <=15
          return [Feature.new("word_length_15")]
        else
          return [Feature.new("word_length_>15")]
      end
    end
  end


  class HasColonCharFeatureExtractor
    #Giving worse results
    def initialize(lines)
    end

    def extract_features(line)
      if (line.include?(":"))
        return [Feature.new("colon_")]
      end
      []
    end
  end

  class NumSentencesBucketingFeatureExtractor
    def initialize(lines)
    end

    #TODO try histogram of sentence counts for each class. Should get better idea about sentence-count boundaries
    def extract_features(line)

      sentences = line.split(/[\.;]/)
      num_sentences = 0
      sentences.each do |s|
        num_sentences += 1 if not s.strip.empty?
      end

      case
        when num_sentences <= 1
          return [Feature.new("sentence_count_1")]
        when num_sentences <= 3
          return [Feature.new("sentence_count_3")]
        when num_sentences <= 5
          return [Feature.new("sentence_count_5")]
        else
          return [Feature.new("sentence_count_>5")]
      end
    end
  end


  class WordFeatureExtractor
    def initialize(training_rows)
      #TODO nothing for now. But, we can filter the words initially - maybe freq threshold
    end

    def extract_features(line)
      features = []
      words = FeatureExtractor.get_words(line)
      words.each do |word|
        features << Feature.new("word_" + word)
      end
      features
    end
  end

  class FirstAndSecondWordFeatureExtractor
    def initialize(training_rows)
      #NOTHING
    end

    def extract_features(line)
      features = []
      words = FeatureExtractor.get_words(line)
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

    def extract_features(line)
      words = FeatureExtractor.get_words(line)
      value = Float(words.join(" ").length/@max_description_length)
      feature = Feature.new("length", value)
      [feature]
    end
  end
end
