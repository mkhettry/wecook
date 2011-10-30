# encoding: UTF-8

require "spec_helper"

describe FeatureExtractor do

  def get_features(line)
    @cut.extract_features(line)
  end

  def get_only_feature(line)
    features = get_features(line)
    features[0] if features
  end

  describe "Fraction Feature Extractor" do
    def is_fraction(line)
      feature = get_only_feature(line)
      feature && feature.name == "fraction"
    end

    before(:each) do
      @cut = FeatureExtractor::HasFractionFeatureExtractor.new(nil)
    end

    it "should extract fraction from text lines" do
      is_fraction("- 1 1/2 C of milk (optional, to de-salt the herring)").should == true
      is_fraction("1 cup diced butternut squash (1/2-inch dice)").should == true
    end

    pending "should extract fraction from &frac lines" do
      is_fraction("&frac12 inch cinnamon stick").should == true
    end

    pending "tricky fractions" do
      #nigella, why does your page suck?
      is_fraction("1/2tsp black pepper powder").should == true
    end

    it "should extract fraction from utf-8 lines" do
      is_fraction("¼ head celeriac").should be true
      is_fraction("½ tsp freshly ground black pepper").should be true
      is_fraction("¾ tsp ground cumin").should be true
    end

    it "should not get fraction for these lines" do
      is_fraction("15g chopped coriander").should be_nil
      is_fraction("(such as trout and/or whitefish)").should be_nil
    end
  end
end
