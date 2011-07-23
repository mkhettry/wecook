require "spec_helper"

describe RecipeDocument do

  describe "extract_lines" do

    describe "where extract_lines returns nothing" do
      it "http://www.theworldwidegourmet.com/recipes/grilled-sardines-with-tomato-sorbet-and-parmesan-tuile/ should return " do
        rd = RecipeDocument.new :file => "spec/fixtures/webpages/GrilledSardinesFromAbe.html", :url => "http://www.theworldwidegourmet.com/recipes/grilled-sardines-with-tomato-sorbet-and-parmesan-tuile/"
        lines = rd.extract_lines
        lines.should include('- 1 green pepper')
      end
    end
  end

  describe "extract_images" do
    it "where images have backslash in them" do
      rd = RecipeDocument.new :file => "spec/fixtures/webpages/sanjeev_kapoor_horrible_html.html", :url =>"http://www.sanjeevkapoor.com/maa-chole-di-dal-foodfood.aspx"
      image_urls = rd.extract_images
      image_urls.each {|s| s.should_not match(/\\/)}
      end
    end

end