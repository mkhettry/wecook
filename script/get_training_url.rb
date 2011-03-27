if ARGV.length != 1 and ARGV.length != 2
  puts "Must specify filename!"
  puts "Usage: get_training_url [dir] <filename>"
  exit -1
end

def write_training_line(f, classification, line)
  f.puts("#{classification}\t#{line.strip}")
end

if (ARGV.length == 1)
  dir = "config/training"
  filename = ARGV[0]
else
  dir = ARGV[0]
  filename = ARGV[1]
end

  urls = File.open(filename, 'r') do |file|
  i=0
  file.each_line do |url|

    url = url.lstrip.rstrip
    next if url.empty? or url.start_with?("#")

    name = dir + "/" +  url.split("/")[2].gsub(".", "_") + "_" + url.hash.abs.to_s;
    next if (File.exists?(name))

    puts "working on #{url}"


    r = RecipeDocument.new(:url => url)
    ingredients = r.extract_ingredients_structured
    directions = r.extract_prep_structured
    if (ingredients.empty? or directions.empty?)
      f = File.open(name + ".tru", 'w')
      f.puts('#' + url)

      puts "Unstructured document. A human will have to classify the lines in the document."
      lines = r.extract_lines
      lines.each do |line|
        write_training_line(f, "OT", line)
      end
    else
      f = File.open(name + ".trs", 'w')
      f.puts('#' + url)

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