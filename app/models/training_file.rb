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

  def summarize(predictions)
    error_lines = []
    line_count = 0
    num_bad_errors = 0

    lines = get_lines
    lines.each_index do |idx|
      line = lines[idx]
      p = predictions[idx]

      line_count += 1
      golden_symbol = LibLinearModel.from_class_str(line.class)
      if p.is_bad_error(golden_symbol)
        num_bad_errors += 1
        error_lines << "#{LibLinearModel.from_class_str(line.class)}\t#{p.top_class}\t#{p.top_two}" + "\t" + line.text[0..128]
      end
    end

    {:num_bad_errors => num_bad_errors, :error_lines =>error_lines}
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