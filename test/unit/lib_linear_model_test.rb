require 'test_helper'

class LibLinearModelTest <  ActiveSupport::TestCase

  test "class data is read correctly in one class model" do
    test_model_data = <<-eodata
      solver_type L2R_LR
      nr_class 1
      label 2
      nr_feature 2
      bias -1
      w
      0.11
      0.12
    eodata
    model = LibLinearModel.new(:model_lines=>test_model_data)
    result = model.model_weights_for_classes

    #check classes
    assert_equal 1, result.length
    assert_equal true, result.has_key?(2)
  end

  test "features are read correctly in one class model" do
    test_model_data = <<-eodata
      solver_type L2R_LR
      nr_class 1
      label 2
      nr_feature 2
      bias -1
      w
      0.11
      0.12
    eodata
    model = LibLinearModel.new(:model_lines=>test_model_data)
    result = model.model_weights_for_classes

    #check feature size
    assert_equal 2, result[2].length
    #check feature values
    assert_equal [1,2], result[2].keys
    assert_equal 0.11, result[2][1]
    assert_equal 0.12, result[2][2]
  end


  test "class data is read correctly in multi class model" do
    test_model_data = <<-eodata
      solver_type L2R_LR
      nr_class 3
      label 5 1 3
      nr_feature 2
      bias -1
      w
      0.11 0.12 0.13
      0.12 -0.22 0.23
    eodata
    model = LibLinearModel.new(:model_lines=>test_model_data)
    result = model.model_weights_for_classes

    #check classes
    assert_equal 3, result.length
    assert_equal [5,1,3], result.keys
  end

  test "predict feature does not exist in model" do
    test_model_data = <<-eodata
      solver_type L2R_LR
      nr_class 3
      label 5 1 3
      nr_feature 2
      bias -1
      w
      0.11 0.12 0.13
      0.12 -0.22 0.23
    eodata

    model = LibLinearModel.new(:model_lines=>test_model_data)
    test_fv = [Feature.from_liblinear_form("3:10")]
    result = model.predict(test_fv)
    assert_equal(1.0/3.0, result[5])
    assert_equal(1.0/3.0, result[1])
    assert_equal(1.0/3.0, result[3])
  end

test "predict" do
    test_model_data = <<-eodata
      solver_type L2R_LR
      nr_class 3
      label 5 1 3
      nr_feature 3
      bias -1
      w
      1 0 0
      0 1 0
      0 0 1
    eodata

    model = LibLinearModel.new(:model_lines=>test_model_data)
    test_fv = [Feature.from_liblinear_form("1:1")]
    result = model.predict(test_fv)
    assert_equal(true, result[5] > result[1])
    assert_equal(true, result[5] > result[3])
    assert_equal(result[1], result[3])
  end


end