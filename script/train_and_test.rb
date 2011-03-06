train_percent=80

files = []
lines = []

Dir.foreach("config/training") do |filename|
  next unless filename =~ /\.trn/
  files << filename
  file = File.new("config/training" + "/" + filename)
  file.each_line do |line|
    lines << line
  end
end

test_lines = []
train_lines = []

lines.each do |line|
  random = rand(100)
  if (random > 79)
    test_lines << line
  else
    train_lines << line
  end
end

puts "Training on #{train_lines.length}, testing on #{test_lines.length}"
nb = NaiveBayes.new

train_lines.each do |line|
  next if line.start_with?("#")
  classification=line[0,2].downcase
  text = line[3,line.length]
  next if text == nil or text.empty?
  nb.train(text, Classifier.map(classification))
end


num_error = 0
bad_error = 0
test_lines.each do |line|
  next if line.start_with?("#")
  classification=line[0,2].downcase
  text = line[3,line.length]
  next if text == nil or text.empty?
  prediction = nb.classify(text)
  actual = Classifier.map(classification)

  if (prediction != actual)
    num_error += 1
    if (actual == :ingredients ||actual == :prep || prediction == :ingredients || prediction == :prep)
      bad_error += 1
    end
  end
end

puts "total test: #{test_lines.length}"
puts "error rate: #{num_error*100/Float(test_lines.length)}"
puts "bad-error rate: #{bad_error*100/Float(test_lines.length)}"


#stats = {}
#train_files.each do |filename|
#    nb.train_on_file("config/training/" + filename)
##  File.open("config/training/" + filename) do |file|
##    # puts "Training on #{filename}"
##    file.each_line do |line|
##      next if line.start_with?("#")
##
##      classification=line[0,2].downcase
##      text = line[3,line.length]
##      next if text == nil or text.empty?
##
##      nb.train(text, map(classification))
##
##      stats[classification] ||= 0
##      stats[classification] = stats[classification] + 1
##    end
##  end
#end
#
#test_files = files - train_files
#
#bad_error = 0
#error = 0
#total = 0
#
#test_files.each do |filename|
#
#  File.open("config/training/" + filename) do |file|
#    new_file = true
#    file.each_line do |line|
#      next if line.start_with?("#")
#
#      classification=line[0,2].downcase
#      text = line[3,line.length]
#      next if text == nil or text.empty?
#
#      actual=nb.classify(text)
#      total += 1
#      expected = Classifier.map(classification)
#      if (expected != actual)
#        if (expected == :ingredients ||expected == :prep || actual == :ingredients || expected == :prep)
#          bad_error += 1
#          if (new_file)
#            puts "---------- #{filename} ----------------"
#            new_file = false
#          end
#          puts "Got: #{actual}-- but was expecting  #{expected}---#{text}"
#        end
#        error += 1
#      end
#    end
#  end
#end
#
#puts "Error rate is #{Float(error*100)/total} %"
#puts "Ingredient/Prep error rate is #{Float(bad_error*100)/total} %"
#puts "Classified #{total} lines"