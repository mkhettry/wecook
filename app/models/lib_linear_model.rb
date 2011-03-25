class LibLinearModel
  LABEL_ID_MAPPING = {"PR" => 0, "IN" => 1, "OT" => 2, "FO" => 3, "NO" => 4, "TA" => 5}

  attr_accessor :name_id_map, :extractors, :model_weights_for_classes

  def read_model_weights!(opt)
    model_file_lines = []
    if opt[:model_file]
      file = File.new(opt[:model_file])
      file.each_line do |line|
        model_file_lines << line
      end
    else
      model_file_lines = opt[:model_lines]
    end

    #TODO ignoring bias for now
    solver_type, nr_classes, labels, nr_features, bias = nil
    current_feature_id = 0
    in_header_section = true
    model_file_lines.each do |line|
      if (in_header_section)
        parts = line.split
        case parts[0]
          when "solver_type" then
            solver_type = parts[1]
          when "nr_class" then
            nr_classes = Integer(parts[1])
          when "label" then
            labels = parts[1..parts.length].collect { |string_label| Integer(string_label) }
          when "nr_feature" then
            nr_features = Integer(parts[1])
          when "bias" then
            bias = Integer(parts[1])
          when "w" then
            in_header_section = false
        end
      else
        current_feature_id += 1
        weights = line.split
        #puts "weights: " + weights.to_s + ", weights.length="+weights.length.to_s + ", labels:"+labels.to_s+", labels.length="+labels.length.to_s
        for i in 0...weights.length
          add_model_weight(LibLinearModelWeight.new(current_feature_id, labels[i], Float(weights[i])))
        end
      end
    end

    check_model(solver_type, nr_classes, labels, nr_features, bias)
  end

  def initialize(opt={})
    @model_weights_for_classes = {}
    @name_id_map = {}
    @extractors = []
    read_model_weights!(opt)
    read_feature_ids_and_extractors!(opt)
  end


  def read_feature_ids_and_extractors!(opt)
    if (opt.has_key? :feature_id_file)
      infile = File.new(opt[:feature_id_file])
      @extractors = infile.readline.split(",").collect{|name| name.strip.constantize.new([])}
      id = 1
      infile.each do |line|
        @name_id_map[line.strip] = id
        id += 1
      end
    end
  end

  def check_model(solver_type, nr_classes, labels, nr_features, bias)
    #check number of classes
    if @model_weights_for_classes.keys.length != nr_classes
      raise Exception, "\nNumber of classes do not match. nr_classes=#{nr_classes}
                          model_weights_for_classes.keys.length=#{model_weights_for_classes.keys.length}
                          model_weights_for_classes.keys=#{model_weights_for_classes.keys[0]}, #{model_weights_for_classes.keys[1]}"
    end

    #check number of features
    @model_weights_for_classes.values.each do |feature_weight_map|
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

  def predict_url(rd)
    lines = rd.extract_lines
    lines.each do |line|
      fv = get_feature_vector(line)
      p = predict(fv)
      puts "#{p.top_class}\t#{p.top_two}\t#{line[0..256]}"
    end
    nil
  end

  def predict_trn(trn)
    error_lines = []
    line_count = 0
    trn.get_lines.each do |line|
      line_count += 1
      fv = get_feature_vector line.text
      p = predict(fv)
      if (p.top_class != LibLinearModel.from_class_str(line.class))
        error_lines << "#{LibLinearModel.from_class_str(line.class)}\t#{p.top_class}\t#{p.top_two}" + "\t" + line.text[0..256]
      end
    end

    puts "#{trn.url} (#{error_lines.length}/#{line_count})"
    error_lines.each do |er|
      puts er
    end
    ""
  end

  def get_top_features(class_name, top_n)
    feature_score = {}
    @name_id_map.each do |name, fid|
      feature_weight = @model_weights_for_classes[LABEL_ID_MAPPING[class_name]][fid]
      feature_score[name] = probability_from_weight_sum(feature_weight)
    end
    feature_score.sort_by{|k,v| -v}[0..top_n]
  end

  def get_feature_weight(feature_name)
    fid = @name_id_map[feature_name]
    m = {}
    LABEL_ID_MAPPING.each do |class_name,class_id|
      m[class_name] = probability_from_weight_sum(@model_weights_for_classes[class_id][fid])
    end
    m
  end

  def get_feature_vector(line)
    fv = []
    @extractors.each do |e|
      features = e.extract_features(line)
      features.each do |feature|
        feature.feature_id = @name_id_map[feature.name]
        fv << feature
      end
    end
    fv
  end



  def predict_class(feature_vector)
    p = predict(feature_vector)
    p.top_class
  end

  class Prediction

    def initialize(map)
      sum = 0.0
      map.values.each do |p|
        sum += p
      end

      @sorted_pairs = []
      map.each do |k,v|
        @sorted_pairs << [k, v/Float(sum)]
      end

      @sorted_pairs.sort! {|a,b| a[1] <=> b[1]}
    end


    def top_class
      @sorted_pairs[-1][0]
    end

    def one_to_s(p)
      (" " + p[0].to_s + "=" + ("%0.2f" % p[1]))
    end

    def to_s
      s = ""
      @sorted_pairs.reverse.each do |p|
        s += one_to_s(p)
      end
      s
    end

    def top_two
      s = ""
      @sorted_pairs[-2..-1].reverse.each do |p|
        s += one_to_s(p)
      end
      s
    end
  end

  #LABEL_ID_MAPPING = {"PR" => 0, "IN" => 1, "OT" => 2, "FO" => 3, "NO" => 4, "TA" => 5}

  def self.from_class_id(class_id)
    case class_id
      when 0 then :PR
      when 1 then :IN
      when 2 then :OT
      when 3 then :FO
      when 4 then :NO
      when 5 then :TA
      else :UN
    end
  end

  def self.from_class_str(class_str)
    case class_str.downcase
        when "pr" then :PR
        when "in" then :IN
        when "ot" then :OT
        when "fo" then :FO
        when "no" then :NO
        when "ta" then :TA
        else :UN
      end

  end
  #feature_vector is a list of features
  def predict(feature_vector)
    prediction = {}
    @model_weights_for_classes.keys.each do |class_id|
      current_probability = probability_for_class(class_id, feature_vector)
      prediction[LibLinearModel.from_class_id(class_id)] = current_probability
    end
    Prediction.new(prediction)
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
      end
    end
    #puts "length of feature vector=#{feature_vector.get_features.length}, weight_sum=#{weight_sum}, features=#{features.join(';')}"
    probability_from_weight_sum(weight_sum)
  end

  def probability_from_weight_sum(w)
    1.0/(1.0 + Math.exp(-w))
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

