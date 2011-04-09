class HueresticLibLinearModel
  THRESHOLD = 2.0

  def initialize(model)
    @model = model
  end

  def predict_trn(trn)
    predictions = predict_lines(trn.filename, trn.get_lines)
    trn.summarize(predictions)

  end

  def predict_lines(name, lines)
    original_predictions = @model.predict_lines(lines)

    category_ranges = CategoryRange.create_ranges_from_predictions(original_predictions)
    ingredient_ranges = []
    category_ranges.each_index do |idx|
      cr = category_ranges[idx]
      if (cr.cat == :IN)
        ingredient_ranges << cr
      end
    end

    # If too many ranges then play it safe and return.
    return original_predictions if ingredient_ranges.length > 3

    ingredient_ranges.sort! { |a,b| a.score <=> b.score}

    top = ingredient_ranges[-1]
    # top_score = 3.5
    # this.score = 0.2
    # this.distance from top score 0.25
    # 0.2 / (top_score * distance)
    # 0.2 / (3.5 * 0.25) => 0.8/3.5 =
    ingredient_ranges.each do |r|
      if (r != top and r.absolute_distance(top) > 1)
        likely = r.score / ((top.score) * r.distance(top, lines.length))
        if (likely < THRESHOLD)
          Rails.logger.warn("Converting r=#{r.pretty_print(lines)}/top=#{top.pretty_print(lines)}:likely=#{likely} in #{name}")
          convert_to_second(original_predictions, r)
        else
          Rails.logger.warn("Not converting r=#{r.pretty_print(lines)}/top=#{top.pretty_print(lines)}:likely=#{likely} in #{name}")
        end
      end
    end

   original_predictions
  end

  def convert_to_second(original_predictions, cr)
    #puts "Trying to convert #{cr.range}"
    #puts "Original predictions are: #{original_predictions}"
    cr.range.each do |idx|
      p = original_predictions[idx]
      Rails.logger.warn("#{p.top_class} -> #{p.top_class(1)}")
      original_predictions[idx] = LibLinearModel::OverriddenPrediction.new(p, p.top_class(1))
    end
  end
end