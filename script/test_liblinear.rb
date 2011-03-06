LABEL_ID_MAPPING = {"PR" => "0", "IN" => "1", "OT" => "2", "FO" => "3", "NO" => 4, "TA" => 5}

def main
  predictions = get_classes_from_file(ARGV[0])
  actuals = get_classes_from_file(ARGV[1])
  lines = get_lines_from_file(ARGV[1])

  puts "predictions: #{predictions.length}\t actual: #{actuals.length}"
  num_errors = 0
  bad_errors = 0
  (0..actuals.length-1).each do |i|
    prediction = predictions[i+1]
    actual = actuals[i]
    #puts "prediction:#{prediction}\tactual:#{actual}"

    if (prediction != actual)
      num_errors += 1
      if (isImportant(prediction) || isImportant(actual))
        bad_errors += 1
        puts "prediction:#{prediction}, actual:#{lines[i]}"
      end
    end
  end

  puts "total: #{actuals.length}"
  puts "num error: #{num_errors}"
  puts "num bad error: #{bad_errors}"
  puts "error rate: #{num_errors*100/Float(actuals.length)}"
  puts "bad error rate: #{bad_errors*100/Float(actuals.length)}"
end


def get_lines_from_file(filename)
  lines = []
  File.new(filename).each_line do |line|
    lines << line
  end
  lines
end

def isImportant(s)
  (s == "0" || s == "1")
end

def get_classes_from_file(filename)
  file = File.new(filename)
  classes = []
  file.each_line do |line|
    classes << line.split()[0]
  end
  classes
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.length != 2
    puts "Usage: ruby create_lib_svm_data.rb.rb <predictions> <acutal-class-mapping>"
  else
    main()
  end
end