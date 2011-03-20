class FeatureExtractor
  IGNORE_WORDS = {"a" => 1, "an" => 1, "the" => 1, "of" => 1, "and" => 1, "to" => 1}

  def self.get_words(line)
    #words = doc.split(/\W+/)
    #words = doc.split
    #split on white space and "-"
    words = line.split(/[\s-]/)

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
