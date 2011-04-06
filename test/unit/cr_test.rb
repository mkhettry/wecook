require 'test_helper'
class CRTest < ActiveSupport::TestCase
  test "empty list" do
    cr = CategoryRange.create_ranges_from_predictions([])
    assert_equal [], cr
  end

  def newp(map)
    LibLinearModel::Prediction.new(map)
  end

  test "list with one element" do
    predictions = [newp(:IN => 0.2, :OT => 0.1)]
    cr = CategoryRange.create_ranges_from_predictions(predictions)
    assert_equal 1, cr.length
    assert_equal :IN, cr[0].cat
    assert_equal 0...1, cr[0].range
  end

  test "list with multiple elements all same" do
    predictions = [newp(:PR => 0.2, :OT => 0.1), newp(:IN => 0.2, :PR => 0.4)]

    cr = CategoryRange.create_ranges_from_predictions(predictions)
    assert_equal 1, cr.length
    assert_equal :PR, cr[0].cat
    assert_equal 0...2, cr[0].range
  end

  test "multiple non contiguous" do
    predictions = [newp(:PR => 0.2, :OT => 0.1), newp(:IN => 0.2, :PR => 0.01)]

    cr = CategoryRange.create_ranges_from_predictions(predictions)
    assert_equal 2, cr.length

    assert_equal :PR, cr[0].cat
    assert_equal 0...1, cr[0].range

    assert_equal :IN, cr[1].cat
    assert_equal 1...2, cr[1].range
  end

  test "multiple non contiguous 2" do
    predictions = [newp(:PR => 0.2, :OT => 0.1), newp(:IN => 0.4, :PR => 0.1), newp(:IN => 0.3, :OT =>0.2), newp(:PR =>0.5, :OT => 0.2)]

    cr = CategoryRange.create_ranges_from_predictions(predictions)
    assert_equal 3, cr.length

    assert_equal :PR, cr[0].cat
    assert_equal 0...1, cr[0].range

    assert_equal :IN, cr[1].cat
    assert_equal 1...3, cr[1].range

    assert_equal :PR, cr[2].cat
    assert_equal 3...4, cr[2].range

    assert_equal "0.67", "%0.2f" % cr[0].score
    assert_equal "1.40", "%0.2f" % cr[1].score
  end

  test "calculate distance" do
    # IN, OT, IN-- distance between the first and last line is 1
    r0 = CategoryRange.new(:IN, 0..1, [0.2])
    r1 = CategoryRange.new(:IR, 2..3, [0.3])

    assert_equal 1, r0.distance(r1, 3)
    assert_equal 1, r1.distance(r0, 3)

    # IN OT IN OT
    assert_equal 0.50, r0.distance(r1, 4)
    assert_equal 0.50, r1.distance(r0, 4)

  end

end