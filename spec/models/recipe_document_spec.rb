require "spec_helper"

describe RecipeDocument do

  describe "extract_lines" do

    describe "where extract_lines returns nothing" do
      it "http://www.theworldwidegourmet.com/recipes/grilled-sardines-with-tomato-sorbet-and-parmesan-tuile/ should return " do
        rd = RecipeDocument.new :file => "spec/fixtures/webpages/GrilledSardinesFromAbe.html", :url => "http://www.theworldwidegourmet.com/recipes/grilled-sardines-with-tomato-sorbet-and-parmesan-tuile/"
        lines = rd.extract_lines
#        lines.length.should be > 1
        lines.should include('- 1 green pepper')
      end
    end


  end

end