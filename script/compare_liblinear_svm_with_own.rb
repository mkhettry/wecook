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
    liblinear_result = Integer(liblinear_results[i])
    own_result = own_results[i]
    own_class_id = LibLinearModel.from_class_str_to_ids(own_result.top_class.to_s)
    outfile.write("< " + liblinear_result.to_s + "\n")
    outfile.write("> " +  own_class_id.to_s + "\t" + own_result.to_s + "\n")
  end
  outfile.close
end

def get_own_results
  own_results = []

  model = LibLinearModel.new(:dir => ARGV[0])
  puts model.to_s
  test_file = File.new(ARGV[1])
  test_file.each_line do |line|
    prediction = compute_probabilities_for_line_data(line, model)
    own_results << prediction
  end
  own_results
end

def compute_probabilities_for_line_data(line, model)
  parts = line.split()
  feature_vector = LibLinearFeatureVector.new(parts[0])
  for i in 1...parts.length
    feature_vector.add_feature_value(parts[i].split(":")[0], parts[i].split(":")[1])
  end

  prediction = model.predict(feature_vector)
  prediction
end



def read_liblinear_results
  results = []

  infile = File.new(ARGV[2])
  infile.each_line do |line|
    results << line.strip
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
