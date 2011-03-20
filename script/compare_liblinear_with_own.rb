#compare the probabilities generated using liblinear with own

def main
  puts "Reading liblinear results"
  liblinear_results = read_liblinear_results()

  puts "Reading own results"
  own_results = get_own_results()

  puts "Writing comparison"
  write_difference(liblinear_results, own_results)
end


def write_difference(liblinear_results, own_results)
  outfile = File.new(ARGV[3],"w")
  for i in 0...liblinear_results.length
    liblinear_result = liblinear_results[i]
    own_result = own_results[i]

    l_result_string = ""
    liblinear_result.keys.each do |class_id|
      l_result_string += "#{class_id}:#{liblinear_result[class_id]}, "
    end

    o_result_string = ""
    own_result.keys.each do |class_id|
      o_result_string += "#{class_id}:#{own_result[class_id]}, "
    end

    outfile.write("< " + l_result_string.rstrip + "\n")
    outfile.write("> " + o_result_string.rstrip + "\n")
  end
  outfile.close
end

def get_own_results
  own_results = []

  model_file = File.new(ARGV[0])
  model_data = model_file.readlines

  model = LibLinearModel.new_liblinear_model(model_data)
  puts model.to_s
  test_file = File.new(ARGV[1])
  test_file.each_line do |line|
    current_probabilities = compute_probabilities_for_line_data(line, model)
    own_results << current_probabilities
  end
  own_results
end

def compute_probabilities_for_line_data(line, model)
  parts = line.split()
  feature_vector = LibLinearFeatureVector.new(parts[0])
  for i in 1...parts.length
    feature_vector.add_feature_value(parts[i].split(":")[0], parts[i].split(":")[1])
  end

  class_probabilities = model.predict(feature_vector)
  class_probabilities.keys.each do |key|
    print "#{key}=>#{class_probabilities[key]}, "
  end
  print "\n"
  class_probabilities
end



def read_liblinear_results
  results = []

  infile = File.new(ARGV[2])
  labels = infile.readline().split()
  infile.each_line do |line|
    current_probabilities = {}
    parts = line.split
    for i in 0...parts.length
      current_probabilities[labels[i]] = Float(parts[i])
    end
    results << current_probabilities
  end
  results
end


if __FILE__ == $PROGRAM_NAME
  if ARGV.length != 4
    puts "Usage: ruby create_lib_svm_data.rb <liblinear-model-file> <test-data> <liblinear-results> <output-file>"
  else
    main()
  end
end
