class TrainingFile

  attr_accessor :url

  def initialize(filename)
    @filename = filename
  end

  def get_lines()
    lines = []
    File.open(@filename).each do |line|
      if  line.start_with? "#"
        @url = line[1..-1]
        next
      end

      next if line.strip.empty?

      tr = TrainingRow.new(line)
      lines << tr unless tr.text.nil? or tr.text.empty?
    end
    lines
  end

  class TrainingRow
    attr_accessor :class, :text

    def initialize(line)
      @class = line[0,2].downcase
      @text = line[3, line.length]
      @text = @text.strip.downcase unless @text.nil?
    end
  end
end