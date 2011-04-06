class CategoryRange
  attr_accessor :cat, :range, :probabilities

  def initialize(cat, range, probabilities)
    @cat = cat
    @probabilities = probabilities
    @range = range
  end

  def score
    s = 0.0
    @probabilities.each do |p|
      s += p
    end
    s
  end

  def self.create_ranges_from_predictions(predictions)
    current_cat = nil
    current_start = -1

    ranges = []
    probabilities = []
    predictions.each_index do |i|
      p = predictions[i]


      if (p.top_class != current_cat)
        if (current_start == -1)
          probabilities << p.probability(p.top_class)
          current_cat = p.top_class
          current_start = i
        else
          ranges << CategoryRange.new(current_cat, current_start...i, probabilities)
          current_cat = p.top_class
          current_start = i
          probabilities = [p.probability(p.top_class)]
        end
      else
        probabilities << p.probability(p.top_class)
      end
    end


    ranges << CategoryRange.new(current_cat, current_start...predictions.length, probabilities) unless current_cat.nil?

    ranges
  end

  def distance(other, total_length)
    if (range.begin < other.range.begin)
      start = range.end
      fin = other.range.begin
    else
      start = other.range.end
      fin = range.begin
    end

    (fin - start) / Float(total_length - 2)
  end
end
