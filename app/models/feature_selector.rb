class FeatureSelector
  attr_accessor :category_counts, :category_counts_for_feature, :selected_features

  def initialize(num_feature = 2000)
    @category_counts = CategoryCounts.new
    @category_counts_for_feature = {}
    @total_lines = 0
    @selected_features = Set.new
    @num_features = num_feature
  end

  def update(category, feature_vector)
    @total_lines += 1
    @category_counts.update(category)
    feature_vector.each do |feature|
      next unless feature.categorical
      category_counts = @category_counts_for_feature.fetch(feature, CategoryCounts.new)
      category_counts.update(category)
      @category_counts_for_feature[feature] = category_counts
    end
  end

  def compute
    category_feature_score = {}
    @category_counts_for_feature.keys.each do |feature|
      @category_counts.category_counts.keys.each do |category|
        feature_score = category_feature_score.fetch(category, [])
        feature_score << [feature, score(category, feature)]
        category_feature_score[category] = feature_score
      end
    end

    category_feature_score.keys.each do |category|
      category_feature_score[category].sort!{|a,b| b[1] <=> a[1]}
      category_feature_score[category][0...@num_features].each do |pair|
        @selected_features.add(pair[0])
      end
    end
  end

  def filter(feature_vector)
    new_fv = []
    feature_vector.each do |feature|
      if feature.categorical
        if @selected_features.member?(feature)
          new_fv << feature
        end
      else
        new_fv << feature
      end
    end
    new_fv
  end

  def f_n1dot(category)
    @category_counts.count(category)
  end

  def f_ndot1(feature)
    @category_counts_for_feature[feature].total_count
  end

  def f_ndot0(feature)
    @total_lines - f_ndot1(feature)
  end

  def f_n0dot(category)
    @category_counts.count_except(category)
  end

  def f_n11(category, feature)
    @category_counts_for_feature[feature].count(category)
  end

  #n01 => category absent and feature present
  def f_n01(category, feature)
    category_count = @category_counts_for_feature[feature]
    category_count.count_except(category)
  end

  def f_n10(category, feature)
    @category_counts.count(category) - @category_counts_for_feature[feature].count(category)
  end


  def f_n00(category, feature)
    #go through other categories and do n10
    out = 0
    @category_counts.category_counts.keys.each do |other_category|
      next if other_category == category
      out += f_n10(other_category, feature)
    end
    out
  end

  #Mutual information based score
  #http://nlp.stanford.edu/IR-book/pdf/13bayes.pdf section: 13.5.1
  def score(category, feature)
    n = Float(@total_lines)
    n11 = Float(f_n11(category, feature))
    n1dot = Float(f_n1dot(category))
    ndot1 = Float(f_ndot1(feature))
    n01 = Float(f_n01(category, feature))
    n0dot = Float(f_n0dot(category))
    n10 = Float(f_n10(category, feature))
    ndot0 = Float(f_ndot0(feature))
    n00 = Float(f_n00(category, feature))

    score = 0.0

    score += (n11/n)*log2(n*n11/(n1dot*ndot1))  if n11 > 0.0 and n1dot > 0.0 and ndot1 > 0.0
    score += (n01/n)*log2((n*n01)/(n0dot*ndot1)) if n01 > 0.0 and n0dot > 0.0 and ndot1 > 0.0
    score += (n10/n)*log2(n*n10/(n1dot*ndot0)) if n10 > 0.0 and n1dot > 0.0 and ndot0 > 0.0
    score += (n00/n)*log2(n*n00/(n0dot*ndot0)) if n00 > 0.0 and n0dot > 0.0 and ndot0 > 0.0

    score
  end

  def log2(count)
    Math.log(count)/Math.log(2)
  end

  class CategoryCounts
    attr_accessor :category_counts, :total_count

    def initialize
      @category_counts = {}
      @total_count = 0
    end

    def update(category)
      @category_counts[category] = @category_counts.fetch(category, 0) + 1
      @total_count += 1
    end

    def count_except(category)
      @total_count - count(category)
    end


    def count(category)
      count = @category_counts[category]
      count.nil? ? 0 : count
    end
  end

end