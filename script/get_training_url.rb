if ARGV.length != 1
  puts "Must specify filename!"
  puts "Usage: get_training_url <filename>"
  exit -1
end

urls = File.open(ARGV[0], 'r') do |file|
  i=0
  file.each_line do |url|

    url = url.lstrip.rstrip
    next if url.empty? or url.start_with?("#")

    name = "config/training/" +  url.split("/")[2].gsub(".", "_") + "_" + url.hash.abs.to_s + ".trn"
    next if (File.exists?(name))

    puts "working on #{url}"
    r = RecipeDocument.new(:url => url)
    lines = r.extract_lines
    f = File.open(name, 'w')
    f.puts('#' + url)
    lines.each do |line|
      f.write("OT\t") # put a leading tab with the default classification (OTher)
      f.puts(line)
    end
  end
end