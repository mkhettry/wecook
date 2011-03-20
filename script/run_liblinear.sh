rails runner script/create_lib_svm_data.rb config/training/
p=`PWD`
(cd $LL_HOME;./train -s 0 $p/training_data.libsvm;)
rails runner script/predict.rb $LL_HOME/training_data.libsvm.model test_data.libsvm predictions_ours.libsvm
(cd $LL_HOME;./predict -b 1 $p/test_data.libsvm training_data.libsvm.model $p/predictions_theirs.libsvm)
echo "Running ours"
rails runner script/test_liblinear.rb predictions_ours.libsvm test_data_description.libsvm
echo "Running theirs"
rails runner script/test_liblinear.rb predictions_theirs.libsvm test_data_description.libsvm

