require 'script/model_builder.rb'

TEST_PERCENTAGE = 80

# 100 files
# idx = 75
# 75..99, 0..54
def get_training_range(total_size, idx)
  num_files = (total_size * TEST_PERCENTAGE) / 100
  if (idx + num_files <= total_size)
    [idx...(idx + num_files)]
  else
    [idx...total_size, 0...num_files - (total_size - idx)]
  end
end

def split_files(files, ranges)
  test_files = []
  train_files = []
  for idx in 0...files.length
    tf = TrainingFile.new('config/training/' + files[idx])
    if not in_range(ranges, idx)
      test_files << tf
      next
    else
      train_files << tf
    end
  end
  return test_files, train_files
end


def in_range(ranges, idx)
  ranges.each do |range|
    if (range.include? idx)
      return true
    end
  end
  false
end


def predict(test_files, logfile)
  model = LibLinearModel.new(:dir => `pwd`.strip)
  m2 = HueresticLibLinearModel.new(model)
  tot_bad_errors = 0
  tot_length = 0
  without_errors = 0
  test_files.each do |trn_file|
    puts "Predicting #{trn_file.filename}"
    h = m2.predict_trn(trn_file)
    if h[:num_bad_errors] == 0
      without_errors += 1
    end
    tot_bad_errors += h[:num_bad_errors]
    tot_length += trn_file.num_lines
    h[:error_lines].each do |e|
      logfile.puts("#{trn_file.filename}\t#{e}")
    end
  end
  #logfile.puts "{#{without_errors}/#{test_files.length}}"
  [tot_bad_errors, tot_length, without_errors]
end

def create_run(run_name)
  Dir.mkdir(run_name)
  log = File.new(run_name + "/run.log", 'w')
  summary = File.new(run_name + "/run.sum", 'w')
  [log, summary]
end

def main(run_name)
  bad_errors = 0
  total_length = 0
  dir = Dir.new('config/training')

  logfile, summaryfile = create_run(run_name)

  files = dir.select {|f| f if f =~ /\.tr[su]$/}
  files.sort! {|a,b| a.hash <=> b.hash}
  for i in 0...files.length
    ranges = get_training_range(files.length, i)
    test_files, train_files = split_files(files, ranges)
    ModelBuilder.build_model_from_training_files(train_files)
    cur_error, cur_length, no_errors = predict(test_files, logfile)
    puts("#{i}:{#{no_errors}/#{test_files.length}}(#{cur_error}/#{cur_length})=#{cur_error/Float(cur_length)}")
    summaryfile.puts("#{i}:{#{no_errors}/#{test_files.length}}(#{cur_error}/#{cur_length})=#{cur_error/Float(cur_length)}")
    summaryfile.flush
    bad_errors += cur_error
    total_length += cur_length
  end
  summaryfile.puts("(#{bad_errors}/#{total_length})=#{bad_errors/Float(total_length)}")
end


if __FILE__ == $PROGRAM_NAME
  if ARGV.length != 1
    puts "Usage: ruby create_lib_svm_data.rb identifier"
  else
    ll_home = `echo $LL_HOME`
    puts ll_home
    if ll_home.strip.empty?
      puts "You must set LL_HOME environment variable."
    else
      main(ARGV[0])
    end
  end
end
