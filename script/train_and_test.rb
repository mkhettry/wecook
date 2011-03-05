train_percent=80

files = []

Dir.foreach("config/training") do |filename|
  next unless filename =~ /\.trn/
  files << filename
end

num_files_to_test = (files.length * train_percent) / 100

puts "Training on #{num_files_to_test}, test on #{files.length - num_files_to_test}"

train_files = files.sample(num_files_to_test)
nb = NaiveBayes.new

stats = {}


train_files.each do |filename|
    nb.train_on_file("config/training/" + filename)
#  File.open("config/training/" + filename) do |file|
#    # puts "Training on #{filename}"
#    file.each_line do |line|
#      next if line.start_with?("#")
#
#      classification=line[0,2].downcase
#      text = line[3,line.length]
#      next if text == nil or text.empty?
#
#      nb.train(text, map(classification))
#
#      stats[classification] ||= 0
#      stats[classification] = stats[classification] + 1
#    end
#  end
end

test_files = files - train_files

bad_error = 0
error = 0
total = 0

test_files.each do |filename|

  File.open("config/training/" + filename) do |file|
    new_file = true
    file.each_line do |line|
      next if line.start_with?("#")

      classification=line[0,2].downcase
      text = line[3,line.length]
      next if text == nil or text.empty?

      actual=nb.classify(text)
      total += 1
      expected = Classifier.map(classification)
      if (expected != actual)
        if (expected == :ingredients ||expected == :prep || actual == :ingredients || expected == :prep)
          bad_error += 1
          if (new_file)
            puts "---------- #{filename} ----------------"
            new_file = false
          end
          puts "Got: #{actual}-- but was expecting  #{expected}---#{text}"
        end
        error += 1
      end
    end
  end
end

puts "Error rate is #{Float(error*100)/total} %"
puts "Ingredient/Prep error rate is #{Float(bad_error*100)/total} %"
puts "Classified #{total} lines"