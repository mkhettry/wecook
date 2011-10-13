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


def predict(model_dir, test_files, logfile)
  model = LibLinearModel.new(:dir => model_dir)
  m2 = HueresticLibLinearModel.new(model)
  tot_bad_errors = 0
  tot_length = 0
  without_errors = 0
  test_files.each do |trn_file|
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
  Dir.mkdir("runs") if Dir.glob("runs").empty?
  dir = "runs/#{run_name}"

  unless Dir.glob(dir).empty?
    alternate_run_name = "#{run_name}_#{Time.now.to_i}"
    puts "#{run_name} is taken. Using #{alternate_run_name}"
    dir = "runs/#{alternate_run_name}"
  end

  Dir.mkdir(dir)

  log = File.new("#{dir}/run.log", 'w')
  summary = File.new("#{dir}/run.sum", 'w')
  [dir, log, summary]
end

def main(run_name, use_svm)
  puts use_svm ? "Using SVM" : "Using Logistic"

  bad_errors = 0
  total_length = 0
  dir = Dir.new('config/training')

  output_dir, logfile, summaryfile = create_run(run_name)

  files = dir.select {|f| f if f =~ /\.tr[su]$/}
  files.sort! {|a,b| a.hash <=> b.hash}
  for i in 0...files.length
    ranges = get_training_range(files.length, i)
    test_files, train_files = split_files(files, ranges)
    ModelBuilder.build_model_from_training_files(output_dir, train_files, use_svm)
    cur_error, cur_length, no_errors = predict(output_dir, test_files, logfile)

    run_summary = "#{i}:{#{no_errors}/#{test_files.length}}(#{cur_error}/#{cur_length})=#{"%0.3f" % (100*cur_error/Float(cur_length))}%"
    puts(run_summary)
    summaryfile.puts(run_summary)
    summaryfile.flush
    bad_errors += cur_error
    total_length += cur_length
  end
  total_summary = "(#{bad_errors}/#{total_length})=#{"%0.4f" % (100*bad_errors/Float(total_length))}%"
  puts "END:" + total_summary
  summaryfile.puts(total_summary)
end


if __FILE__ == $PROGRAM_NAME
  use_svm = ARGV.delete("-s")
  if ARGV.length != 1
    puts "Usage: ruby create_lib_svm_data.rb identifier [-s]"
  else
    ll_home = `echo $LL_HOME`.strip
    puts "Liblinear found in #{ll_home}"

    if ll_home.empty?
      puts "You must set LL_HOME environment variable."
    elsif Dir.glob("#{ll_home}/train").empty?
      puts "Could not find \"train\" in #{ll_home}. Perhaps you need to build it first?"
    else
      main(ARGV[0], !use_svm.nil?)
    end
  end
end
