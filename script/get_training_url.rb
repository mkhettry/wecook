if ARGV.length != 1
  puts "Must specify filename!"
  puts "Usage: get_training_url <filename>"
  exit -1
end

def write_training_line(f, classification, line)
  f.puts("#{classification}\t#{line}")
end

urls = File.open(ARGV[0], 'r') do |file|
  i=0
  file.each_line do |url|

    url = url.lstrip.rstrip
    next if url.empty? or url.start_with?("#")

    name = "config/training/" +  url.split("/")[2].gsub(".", "_") + "_" + url.hash.abs.to_s + ".trn"
    next if (File.exists?(name))

    puts "working on #{url}"

    f = File.open(name, 'w')
    f.puts('#' + url)

    r = RecipeDocument.new(:url => url)
    ingredients = r.extract_ingredients_structured
    directions = r.extract_prep_structured
    if (ingredients.empty? or directions.empty?)
      puts "Unstructured document. A human will have to train it"
      lines = r.extract_lines
      lines.each do |line|
        write_training_line(f, "OT", line)
      end
    else
      puts "Structured document found"
      ingredients.each do |i|
        write_training_line(f, "IN", i)
      end

      directions.each do |d|
        write_training_line(f, "PR", d)
      end

    end



  end
end