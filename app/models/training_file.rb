class TrainingFile

  attr_accessor :url, :filename, :num_lines

  def initialize(filename)
    @filename = filename
    @lines = []
  end

  def get_lines()
    @lines unless @lines.empty?
    lines = []
    File.open(@filename).each do |line|
      if  line.start_with? "#"
        @url = line[1..-1]
        next
      end

      next if line.strip.empty?

      tr = TrainingRow.new(line)
      lines << tr if tr.valid_line?
    end
    @num_lines = lines.length
    @lines = lines
  end

  def get_lines_only
    get_lines.collect {|line| line.text}
  end

  # Returns an array of feature vectors.
  def to_feature_vectors(extractors)

    extractors.each do |e|
      e.initialize_document(@lines.collect {|line| line.text})
    end

    feature_vectors = []
    get_lines.each_index do |idx|
      line = @lines[idx]
      fv = []
      extractors.each do |e|
        cur_fv = e.extract_features(idx, line.text)
        fv += cur_fv unless cur_fv.nil?
      end
      feature_vectors << fv
    end

    feature_vectors
  end

  def get_category(idx)
    line = @lines[idx]
    LibLinearModel.from_class_str_to_ids(line.class)
  end

  def summarize_line(line, p)
    "#{LibLinearModel.from_class_str(line.class)}\t#{p.top_class}\t#{p.top_two}" + "\t" + line.text[0..80]
  end

  def summarize(predictions)
    error_lines = []
    line_count = 0
    num_bad_errors = 0
    errors = 0

    lines = get_lines
    summarized_lines = []
    lines.each_index do |idx|
      line = lines[idx]
      p = predictions[idx]

      line_count += 1
      golden_symbol = LibLinearModel.from_class_str(line.class)
      if p.is_bad_error(golden_symbol)
        num_bad_errors += 1
        error_lines << summarize_line(line, p)
      elsif p.is_error(golden_symbol)
        errors += 1
      end
      summarized_lines << summarize_line(line, p)
    end

    {:num_bad_errors => num_bad_errors, :error_lines =>error_lines, :lines => summarized_lines}
  end


  class TrainingRow
    attr_accessor :class, :text

    def initialize(line)
      @class = line[0,2].downcase
      @text = line[3, line.length]
      @text = @text.strip.downcase unless @text.nil?
    end

    def valid_line?
      if @text.nil? or @text.empty?
        return false
      end

      if @text =~ /[a-z]/i
        true
      else
        false
      end
    end
  end
end