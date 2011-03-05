class Classifier
  attr_reader :fc, :cc
  IGNORE_WORDS = {"a" => 1, "an" => 1, "the" => 1, "of" => 1, "and" => 1, "to" => 1}

  def initialize(code=nil)
    @fc = {}
    @cc = {}
    if (code == nil)
      @getfeatures = method(:entryfeatures)
    else
      @getfeatures = method(code)
    end
  end

  def train(doc, cat)
    #features = getwords(doc)
    features = @getfeatures.call(doc)
    features.each do |f|
      incf(f,cat)
    end

    incc(cat)
  end

  # increase the count of a feature/category
  def incf(f,cat)
    @fc[f] ||= {}
    @fc[f][cat] ||= 0
    @fc[f][cat] += 1
  end

  # increase the count of a category
  def incc(cat)
    @cc[cat] ||= 0
    @cc[cat] += 1
  end

  def catcount(cat)
    @cc[cat] == nil ? 0 : Float(@cc[cat])
  end

  # the number of times a feature has appeared in a category
  def fcount(f,cat)
    if @fc[f] && @fc[f][cat]
      Float(@fc[f][cat])
    else
      0
    end
  end

  def totalcount()
    @cc.values.sum
  end

  def categories()
    @cc.keys
  end

  def fprob(f,cat)
    if catcount(cat) == 0
      0
    end

    fcount(f,cat) / catcount(cat)
  end

  def weighted_probability(f,cat)
    basicprob=fprob(f,cat)
    totals=0
    @cc.keys.each do |c|
      totals += fcount(f,c)
    end

    #puts "wp: #{f}/#{cat}- basicprob=#{basicprob},totals=#{totals}"
    ((0.33*1) + (totals*basicprob)) / (totals + 1)
  end


  def getwords(doc)
    #words = doc.split(/\W+/)
    #words = doc.split
    #split on white space and "-"
    words = doc.split(/[\s-]/)

    words = words.select {|w| w.strip.length > 0 and IGNORE_WORDS[w].nil?}
    words.collect { |w| w.downcase}
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

  def entryfeatures(doc)
    features = []
    words = getwords(doc)

    # each word is a feature
    words.each do |w|
      features << [:word, w]
    end


    features << [:w1, words[0]]
    features << [:w2, words[1]] if words.length > 1

    features << [:has_fraction, has_fraction(doc)]
    features << [:word_count, words.length]
    features << [:last_word, words[-1]]    
  end

  def has_fraction(doc)
    !doc.match(/\d\/\d/).nil?
  end

  def classify(item)
    max = 0.0
    best = nil
    cc.keys.each do |c|
      p = prob(item, c)
#      puts "doing #{c}, prob is #{p}"
      if (p > max)
        max = p
        best = c
      end
    end
    best
  end

  def classify_document(rd)
    ingredients = []
    prep = []
    notes = []

    rd.extract_lines.each do |line|
      cl=classify(line)
      if (cl == :ingredients)
        ingredients << line
      elsif (cl == :notes)
        notes << line
      elsif (cl == :prep)
        prep << line
      end
    end

    puts "ingredients"
    puts ingredients.join("\n")

    puts "prep"
    puts prep.join("\n")

    puts "notes"
    puts notes.join("\n")
  end

  def classify_url(url)
    classify_document(RecipeDocument.new(:url => url))
  end

  def selftrain2()
    t2('config/training/ingredients.txt', :ingredients)
    t2('config/training/other.txt', :other)
    t2('config/training/notes.txt', :notes)
    t2('config/training/prep.txt', :prep)
  end

  def self.map(st)
    case st.downcase
      when "ot" then :other
      when "pr" then :prep
      when "in" then :ingredients
      when "no" then :notes
      when "fo" then :info
      when "ta" then :tag
    end
  end
  
  def train_on_dir(dir)
    Dir.foreach(dir) do |filename|
      next unless filename =~ /\.trn/
      train_on_file(dir + "/" + filename)
    end
  end

  def train_on_file(filename)
    File.open(filename) do |file|
      # puts "Training on #{filename}"
      file.each_line do |line|
        next if line.start_with?("#")

        classification=line[0,2].downcase
        text = line[3,line.length]
        next if text == nil or text.empty?

        train(text, Classifier.map(classification))
      end
    end
  end

  def test_file(filename)
    File.open(filename) do |file|
      file.each_line do |line|
        next if line.start_with?("#")

        expected=Classifier.map(line[0,2].downcase)

        text = line[3,line.length]

        next if text == nil or text.empty?
        actual=classify(text)

        if (actual != expected)
          puts "a=#{actual}:e=#{expected}--#{text}"
        else
          puts "#{actual}--#{text}"
        end
      end
    end
  end

  def t2(filename,cat)
    File.open(filename, 'r') do |file|
      file.each_line do |line|
        train(line, cat)
      end
    end

  end

end
