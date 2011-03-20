class LibLinearModel

  attr_reader :model_weights_for_classes, :solver_type

  def self.new_liblinear_model(opt={})

    model_file_lines = []
    if opt[:file]
      file = File.new(opt[:file])
      file.each_line do |line|
        model_file_lines << line
      end
    else
      model_file_lines = opt[:lines]
    end

    model = LibLinearModel.new
    #TODO ignoring bias for now
    solver_type, nr_classes, labels, nr_features, bias = nil
    current_feature_id = 0
    in_header_section = true
    model_file_lines.each do |line|
      if(in_header_section)
        parts = line.split
        case parts[0]
          when "solver_type" then solver_type = parts[1]
          when "nr_class" then nr_classes = Integer(parts[1])
          when "label" then labels = parts[1..parts.length].collect{|string_label| Integer(string_label)}
          when "nr_feature" then nr_features = Integer(parts[1])
          when "bias" then bias = Integer(parts[1])
          when "w" then in_header_section = false
        end
      else
        current_feature_id += 1
        weights = line.split
        #puts "weights: " + weights.to_s + ", weights.length="+weights.length.to_s + ", labels:"+labels.to_s+", labels.length="+labels.length.to_s
        for i in 0...weights.length
          model.add_model_weight(LibLinearModelWeight.new(current_feature_id, labels[i], Float(weights[i])))
        end
      end
    end

    check_model(model, solver_type, nr_classes, labels, nr_features,bias)

    model
  end

  def self.check_model(model, solver_type, nr_classes, labels, nr_features, bias)
    model_weights_for_classes = model.model_weights_for_classes

    #check number of classes
    if model_weights_for_classes.keys.length != nr_classes
      raise Exception, "\nNumber of classes do not match. nr_classes=#{nr_classes}
                          model_weights_for_classes.keys.length=#{model_weights_for_classes.keys.length}
                          model_weights_for_classes.keys=#{model_weights_for_classes.keys[0]}, #{model_weights_for_classes.keys[1]}"
    end

    #check number of features
    model_weights_for_classes.values.each do |feature_weight_map|
      if (feature_weight_map.length != nr_features)
        raise Exception, "Number of feature do not match"
      end
    end

    #check labels
    if labels.length != nr_classes
      raise Exception, "\nIncorrect number of labels specified in the model data
                          nr_classes=#{nr_classes}, labels.length=#{labels.length}, labels=#{labels}"
    end

  end


  def predict_class(feature_vector)
    class_probs = predict(feature_vector)
    class_probs.sort_by{|k,v| v}[-1][0]
  end

  #feature_vector is a list of features
  def predict(feature_vector)
    class_probabilities = {}
    classes = @model_weights_for_classes.keys
    sum = 0.0
    classes.each do |class_id|
      current_probability = probability_for_class(class_id, feature_vector)
      class_probabilities[class_id] = current_probability
      sum += current_probability
    end

    class_probabilities.keys.each do |key|
      class_probabilities[key] = class_probabilities[key]/sum
    end
    class_probabilities
  end

  #TODO make below methods private
  def initialize
    @model_weights_for_classes = {}
    @solver_type = nil
  end

  def solver_type=(solver_type)
    @solver_type = solver_type
  end

  def add_model_weight(model_weight)
    if !@model_weights_for_classes.has_key?(model_weight.class_id)
      @model_weights_for_classes[model_weight.class_id] = {}
    end
    #@model_weights_for_classes[model_weight.class_id] ||= {}
    #puts "adding model_weight with class_id: " + model_weight.class_id.to_s + ", value="+model_weight.weight_value.to_s
    @model_weights_for_classes[model_weight.class_id][model_weight.feature_id] = model_weight.weight_value
  end

  def probability_for_class(class_id, feature_vector)
    weight_sum = 0.0
    feature_vector.each do |feature|
      if @model_weights_for_classes[class_id].has_key?(feature.feature_id)
        weight_sum += @model_weights_for_classes[class_id][feature.feature_id] * feature.value
      else
        puts "could not find feature-id:#{feature.feature_id} in model for class: #{class_id}"
      end
    end
    #puts "length of feature vector=#{feature_vector.get_features.length}, weight_sum=#{weight_sum}, features=#{features.join(';')}"
    1.0/(1.0 + Math.exp(-weight_sum))
  end

  def to_s
    out_string = ""
    @model_weights_for_classes.keys.each do |class_id|

      out_string << "class_id=#{class_id}, weights are:\n"
      @model_weights_for_classes[class_id].keys.each do |feature_id|
        out_string << "(#{feature_id}, #{@model_weights_for_classes[class_id][feature_id]})+\n"
      end
      out_string << "\n"
    end
    out_string
  end

end

