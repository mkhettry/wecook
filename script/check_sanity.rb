
Dir.foreach("config/training") do |filename|
  next unless filename =~ /\.trn$/

  file = File.new("config/training" + "/" + filename)
  file_map = {}
  file.each_line do |line|
    classification=line[0,2].downcase
    text = line[3,line.length]
    file_map[classification] = text
  end

  if file_map["in"].nil?
    puts "No ingredients found in #{filename}"
  end

  if file_map["pr"].nil?
    puts "No prep found in #{filename}"
  end

end
