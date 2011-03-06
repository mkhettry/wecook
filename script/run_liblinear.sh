ruby create_lib_svm_data.rb ../config/training/
(cd /Users/srinidhi/workspace/ruby/work/classifiers/liblinear-1.7;./train -s 0 /Users/srinidhi/workspace/ruby/cooks/script/training_data.libsvm;./predict -b 1 /Users/srinidhi/workspace/ruby/cooks/script/test_data.libsvm training_data.libsvm.model /Users/srinidhi/workspace/ruby/cooks/script/predictions.libsvm)
ruby test_liblinear.rb predictions.libsvm test_data_description.libsvm

