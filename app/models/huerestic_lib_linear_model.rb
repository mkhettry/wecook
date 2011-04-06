class HueresticLibLinearModel
  THRESHOLD = 1.0

  def initialize(model)
    @model = model
  end

  def predict_trn(trn)
    original_predictions = @model.predict_trn_only(trn)

    category_ranges = CategoryRange.create_ranges_from_predictions(original_predictions)
    ingredient_ranges = []
    category_ranges.each_index do |idx|
      cr = category_ranges[idx]
      if (cr.cat == :IN)
        ingredient_ranges << cr
      end
    end

    ingredient_ranges.sort! { |a,b| a.score <=> b.score}

    top = ingredient_ranges[-1]
    # top_score = 3.5
    # this.score = 0.2
    # this.distance from top score 0.25
    # 0.2 / (top_score * distance)
    # 0.2 / (3.5 * 0.25) => 0.8/3.5 =
    ingredient_ranges.each do |r|
      if (r != top)
        likely = r.score / ((top.score) * r.distance(top, trn.num_lines))
        if (likely < THRESHOLD)
          Rails.logger.warn("Converting #{r} to next class because likely is #{likely}")
          convert_to_second(original_predictions, r)
        end
      end
    end

    original_predictions
  end

  def convert_to_second(original_predictions, cr)
    puts "Trying to convert #{cr.range}"
    puts "Original predictions are: #{original_predictions}"
    cr.range.each do |idx|
      puts "Lookig for #{idx}"
      p = original_predictions[idx]
      original_predictions[idx] = LibLinearModel::OverriddenPrediction.new(p, p.top_class(1))
    end
  end
end