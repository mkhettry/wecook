# encoding: utf-8
require "spec_helper"

describe RecipeDocument do

  describe "extract_lines" do

    describe "where extract_lines returns nothing" do
      it "http://www.theworldwidegourmet.com/recipes/grilled-sardines-with-tomato-sorbet-and-parmesan-tuile/ should return " do
        rd = RecipeDocument.new :file => "spec/fixtures/webpages/GrilledSardinesFromAbe.html",
                                :url => "http://www.theworldwidegourmet.com/recipes/grilled-sardines-with-tomato-sorbet-and-parmesan-tuile/"
        lines = rd.extract_lines
        lines.should include('- 1 green pepper')
      end
    end
  end

  describe "extract_images" do

    describe "imaging scoring" do
      it "sesame balls, images are scored by position" do
        rd = RecipeDocument.new :file => "spec/fixtures/webpages/SesameAlmondBrownRiceBallsRecipe.html",
                                :url =>"http://www.101cookbooks.com/archives/sesame-almond-brown-rice-balls-recipe.html"
        image_urls = rd.score_images
        image_urls.sort_by { |k, v| v}.pop(1)[0][0].should == "/mt-static/images/food/brown_rice_balls.jpg"
      end

      it "weeds out smaller images" do
        rd = RecipeDocument.new :file => "spec/fixtures/webpages/SesameAlmondBrownRiceBallsRecipe.html",
                                :url =>"http://www.101cookbooks.com/archives/sesame-almond-brown-rice-balls-recipe.html"
        image_urls = rd.score_images
        image_urls.should_not =~ /pancakes/
      end
    end

    it "where images have backslash in them" do
      rd = RecipeDocument.new :file => "spec/fixtures/webpages/sanjeev_kapoor_horrible_html.html",
                              :url =>"http://www.sanjeevkapoor.com/maa-chole-di-dal-foodfood.aspx"
      image_urls = rd.extract_images
      image_urls.each {|s| s.should_not match(/\\/)}
    end

    it "evolving tastes" do
      rd = RecipeDocument.new :file => "spec/fixtures/webpages/evolving_tastes.html",
                              :url =>"http://evolvingtastes.blogspot.com/2009/12/shevayachi-kheer.html"
      image_urls = rd.extract_images
      image_urls.should_not include("http://photos1.blogger.com/x/blogger2/5207/2825/1600/z/665227/gse_multipart50612.jpg")
      image_urls.should include("http://farm3.static.flickr.com/2738/4172868824_70393f2e39.jpg")
    end

    it "the cooker gets images without alt text" do
      rd = RecipeDocument.new :file => "spec/fixtures/webpages/the_cooker.html",
                              :url =>"http://the-cooker.blogspot.com/2008/12/quinoa-carrot-pulao.html"
      image_urls = rd.extract_images
      image_urls.length.should == 1
    end

    it "guacamole hummus" do
      rd = RecipeDocument.new :file => "spec/fixtures/webpages/guacamole_hummus.html",
                              :url =>"http://www.shutterbean.com/guacamole-hummus/"
      image_urls = rd.extract_images(10)
      image_urls.length.should == 9
      image_urls.each {|s| s.should_not match(/ads|banner/) }
    end

    it "spice spoon" do
      rd = RecipeDocument.new :file => "spec/fixtures/webpages/spice_spoon.html",
                              :url =>"http://www.thespicespoon.com/blog/strawberry-yoghurt-parfait-in-the-persian-manner/"
      image_urls = rd.extract_images(10)
      image_urls.length.should == 4
      image_urls.should include("http://www.thespicespoon.com/blog/wp-content/uploads/2011/06/strawberry-parfait.jpg")
    end

    pending "extract images from epicurious com one" do
      # small image on page:
      #   <img src="/images/recipesmenus/2011/2011_january/362954_116.jpg" class="photo scale_down" alt="Swiss Chard Lasagna with Ricotta and Mushroom">
      # big image on different page
      #   <img src="/images/recipesmenus/2011/2011_january/362954.jpg" alt="Swiss Chard Lasagna with Ricotta and Mushroom">
      # same image is used with different css.
      r = RecipeDocument.new(
          :url => 'http://www.epicurious.com/recipes/food/views/Swiss-Chard-Lasagna-with-Ricotta-and-Mushroom-362954',
          :file => 'spec/fixtures/webpages/Swiss Chard Lasagna with Ricotta and Mushroom Recipe at Epicurious.com.html')
      images = r.extract_images
      assert_equal ["http://www.epicurious.com/images/articlesguides/holidays/passover/spring-navpromo-RM.jpg", "http://www.epicurious.com/images/recipesmenus/2011/2011_january/362954_116.jpg" ], images
    end

    pending "nandyala should pick image" do
      rd = RecipeDocument.new :file => "spec/fixtures/webpages/nandyala.html",
                              :url =>"http://www.nandyala.org/mahanandi/archives/2007/05/10/mirchi-ka-salan-from-hyderabad/"
      image_urls = rd.extract_images(10)
      image_urls.length.should == 3
      end
  end

  describe "sites with iframes" do
    it "gojee" do
      opts = RecipeDocument.redirect_if_needed(
          :url => "http://www.gojee.com/links/1094",
          :file => fixture_path + '/webpages/Gojee - Spice-Roasted Chickpeas.html')
      opts[:url].should eql "http://www.whatwouldcathyeat.com/2010/12/heart-loving-holiday-recipe-spice-roasted-chickpeas/"
      opts.keys.should eql [:url]
    end

    it "foodbuzz" do
        opts = RecipeDocument.redirect_if_needed(
                  :url => 'http://www.foodbuzz.com/blogs/3623585-triple-berry-orange-glazed-shortbread',
                  :file => fixture_path + '/webpages/foodbuzz-triple-berry.html')
        opts[:url].should eql "http://www.sprinkledwithflour.com/2011/05/triple-berry-orange-shortbread.html"
        opts.keys.should eql [:url]
    end
  end

  describe "structured sites" do
    it "should extract ingredients/prep for nytimes the minimalist" do
      r = RecipeDocument.new(
          :url => "http://dinersjournal.blogs.nytimes.com/2011/09/30/the-minimalist-pasta-with-cauliflower/",
          :file => "spec/fixtures/webpages/PastaWithCauliflowerNYTimes.html")
      prep = r.extract_prep_structured
      prep[1].should match(/2. Meanwhile, in a large deep skillet over medium-low heat/)

      ingredients = r.extract_ingredients_structured
      ingredients.first.should == "1 head cauliflower, about 1 pound"
      ingredients[1].should == "Salt and black pepper"
      ingredients.last.should == "1 cup coarse bread crumbs."
    end
  end
end