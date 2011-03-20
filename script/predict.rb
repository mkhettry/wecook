
def main()

  model = LibLinearModel.new(:model_file=>ARGV[0])
  test_file = File.new(ARGV[1])
  output_file = File.new(ARGV[2],"w")

  output_file.puts("")
  test_file.each_line do |line|
    fv = get_feature_vector(line)
    output_file.puts(model.predict_class(fv))
  end

  output_file.close
  test_file.close
end

def get_feature_vector(line)
  fv = []
  parts = line.split()
  for i in 1...parts.length
    fv << Feature.from_liblinear_form(parts[i])
  end
  fv
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.length != 3
    puts "Usage: ruby create_lib_svm_data.rb <liblinear-model-file> <test-data> <output-file>"
  else
    main()
  end
end
