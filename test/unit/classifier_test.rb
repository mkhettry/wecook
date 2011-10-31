require 'test_helper'

class ClassifierTest <  ActiveSupport::TestCase
  test "feature extractor deals with 120ml" do
    nb = NaiveBayes.new
    features = nb.entryfeatures("120ml quinoa")
    assert features.detect { |f| f == [:w1, "120"] }
    assert features.detect { |f| f == [:w2, "ml"] }
  end

  test "stop words are stripped out" do
    nb = NaiveBayes.new
    features = nb.entryfeatures("a pinch of salt")
    assert !features.detect { |f| f == [:w, "a"]}
    assert !features.detect { |f| f == [:w, "of"]}
  end

  test "feature extractor handles 3x5 correctly" do
    nb = NaiveBayes.new
    features = nb.entryfeatures("3x5 card")
  end
end