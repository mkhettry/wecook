class HueresticLibLinearModel
  THRESHOLD = 2.0

  def initialize(model)
    @model = model
  end

  def predict_trn(trn)
    predictions = predict_lines(trn.filename, trn.get_lines)
    trn.summarize(predictions)
  end

  def predict_url(url)
    rd = RecipeDocument.new(:url => url)
    if (rd.is_structured?)
      ing = rd.extract_ingredients_structured
      prep = rd.extract_prep_structured
      puts "ing " + ing
      puts "prep " + prep
    else
      lines = rd.extract_lines
      predictions = predict_lines(url, lines)
      lines.each_index do |idx|
        p = predictions[idx]
        puts "#{p.top_two}" + "\t" + lines[idx][0..80]
      end
    end

  end

  def get_ranges_for_category(category_ranges, category)
    ingredient_ranges = []
    category_ranges.each_index do |idx|
      cr = category_ranges[idx]
      if (cr.cat == category)
        ingredient_ranges << cr
      end
    end
    ingredient_ranges
  end

  def predict_lines(name, lines)
    original_predictions = @model.predict_lines(lines)

    category_ranges = CategoryRange.create_ranges_from_predictions(original_predictions)
    ingredient_ranges = get_ranges_for_category(category_ranges, :IN)
    prep_ranges = get_ranges_for_category(category_ranges, :PR)

    # If too many ranges then play it safe and return.
    override_ingredient_ranges(ingredient_ranges, original_predictions, lines, name)
    override_prep_ranges(prep_ranges, original_predictions, lines, name)

    original_predictions
  end

  def override_prep_ranges(prep_ranges, original_predictions, lines, name)
    return if prep_ranges.length > 3

    prep_ranges.sort! { |a,b| a.score <=> b.score}

    top = prep_ranges[-1]
    expand_top_range(top, original_predictions, lines, name, :PR) unless top.nil?
  end

  def override_ingredient_ranges(ingredient_ranges, original_predictions, lines, name)
    return if ingredient_ranges.length > 3

    ingredient_ranges.sort! { |a,b| a.score <=> b.score}

    top = ingredient_ranges[-1]

    expand_top_range(top, original_predictions, lines, name, :IN) unless top.nil?

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
          convert_range_to_second(original_predictions, r)
        else
          Rails.logger.warn("Not converting r=#{r.pretty_print(lines)}/top=#{top.pretty_print(lines)}:likely=#{likely} in #{name}")
        end
      end
    end

  end

  def promote_neighbor(idx_before, original_predictions, lines, name, category)
    op = original_predictions[idx_before]
    return if op.kind_of?(LibLinearModel::OverriddenPrediction)

    if op.top_class(1) == category
      if (op.delta_between(0,1) / op.probability(op.top_class)) < 0.2
        convert_to_second(idx_before, original_predictions)
        Rails.logger.warn("Promoted neighbor #{lines[idx_before].text[0..12]} #{op.top_class} -> #{op.top_class(1)} in #{name}")
      end
    end
  end

  def expand_top_range(top, original_predictions, lines, name, category)
    idx_before = top.begin - 1
    idx_after = top.end

    promote_neighbor(idx_before, original_predictions, lines, name, category) if idx_before >= 0
    promote_neighbor(idx_after, original_predictions, lines, name, category) if (idx_after < original_predictions.length)

  end

  def convert_range_to_second(original_predictions, cr)
    #puts "Trying to convert #{cr.range}"
    #puts "Original predictions are: #{original_predictions}"
    cr.range.each do |idx|
      p = original_predictions[idx]
      Rails.logger.warn("#{p.top_class} -> #{p.top_class(1)}")
      convert_to_second(idx, original_predictions)
    end
  end

  def convert_to_second(idx, original_predictions)
    p = original_predictions[idx]
    original_predictions[idx] = LibLinearModel::OverriddenPrediction.new(p, p.top_class(1))
  end

end