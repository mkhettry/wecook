require 'test_helper'

class RecipeDocumentTest < ActiveSupport::TestCase
  test "extract lines 101cookbooks with embedded link tag in line" do
    r = RecipeDocument.new(
        :url => "http://www.101cookbooks.com/archives/carrot-and-fennel-soup-recipe.html",
        :string => <<-eohtml
<div id="recipe">
<p>2 tablespoons <a href="http://www.ooliveoil.com/product_citrus.php?n=O%20blood%20orange%20olive%20oil">blood orange olive oil</a> or 5 tablespoons fresh orange juice</p>
<p>lots of freshly grated Parmesan cheese</p>

        eohtml
    )
    lines = r.extract_lines
  assert_equal "2 tablespoons blood orange olive oil or 5 tablespoons fresh orange juice", lines[0]
  assert_equal "lots of freshly grated Parmesan cheese", lines[1]
  end

  test "extract lines blogspot evolvingtastes" do
    r = RecipeDocument.new(
        :url => "http://evolvingtastes.blogspot.com/2010/11/insalata-caprese.html",
        :string => <<-eohtml
        <span style="font-weight:bold;">Insalata Caprese</span><br /><br />Serves 2<br /><br /><span style="font-weight:bold;">Ingredients</span><br /><br />8-10 oz (about 2-4, depending on size) ripe tomatoes<br />4 oz fresh mozzarella cheese (usually 1 medium ball)<br />10-15 basil leaves<br />big pinch of coarse salt<br />freshly ground pepper<br />about 1 Tablespoon extra virgin olive oil<br /><br /><span style="font-weight:bold;">Method</span><br /><br />Slice the tomatoes into rounds. Drain the mozzarella cheese from its brine and slice it into rounds. <br />

    eohtml
    )
    assert_equal [
                     "Insalata Caprese",
                     "Serves 2",
                     "Ingredients",
                     "8-10 oz (about 2-4, depending on size) ripe tomatoes",
                     "4 oz fresh mozzarella cheese (usually 1 medium ball)",
                     "10-15 basil leaves",
                     "big pinch of coarse salt",
                     "freshly ground pepper",
                     "about 1 Tablespoon extra virgin olive oil",
                     "Method",
                     "Slice the tomatoes into rounds. Drain the mozzarella cheese from its brine and slice it into rounds."
                 ],
                 r.extract_lines
  end

  test "extract lines blogspot ginger-and-garlic" do

    r = RecipeDocument.new(
        :url => "foo",
        :string => <<-eohtml
          <div style="text-align: justify;"><b>Recipe: </b>Celery root soup</div><div style="text-align: justify;">Serves 4</div><div style="text-align: justify;"><b>Ingredients:</b></div><div style="text-align: justify;"><i>1 large celery root</i></div><div style="text-align: justify;"><i>3 stalks of celery</i></div><div style="text-align: justify;"><i>1 leek</i></div><div style="text-align: justify;"><i>6C water</i></div><div style="text-align: justify;"><i>olive oil</i></div><div style="text-align: justify;"><i>salt &amp; pepper</i></div><div style="text-align: justify;"><i>red chili flakes</i></div><div style="text-align: justify;"><br />
          </div><div style="text-align: justify;"><b>Recipe:</b></div><div style="text-align: justify;"><i>Prepare the celery root. First chop off the celeri-sh stalks attached to the root and then run the root through running water for a few minutes making sure to remove as much dirt as you can. Then using your knife peel of the outer skin. Then chop the peeled celery root into small cubes.</i></div><div class="separator" style="clear: both; text-align: center;"><img border="0" height="480" src="http://1.bp.blogspot.com/_RAwXc00juq0/TOl70iPCIsI/AAAAAAAAAsc/r6qZgTcxtDw/s640/IMG_2933-2.jpg" width="640" /></div><div style="text-align: justify;"><i><br />
          </i></div><div style="text-align: justify;"><i>Prepare the celery and the leek. Chop the celery sticks into small pieces. Chop the leek into small pieces and wash well (dirt gets trapped inside the leek leaves, so cleaning them after chopping is the best way to get rid of the dirt.</i></div><div class="separator" style="clear: both; text-align: center;"><img border="0" height="480" src="http://4.bp.blogspot.com/_RAwXc00juq0/TOl78GJhaQI/AAAAAAAAAsg/TCRjYDags9Q/s640/IMG_2935-2.jpg" width="640" /></div><div style="text-align: justify;"><i><br />
    eohtml
    )
    assert_lines ["Recipe: Celery root soup",
                 "Serves 4",
                 "Ingredients:",
                 "1 large celery root",
                 "3 stalks of celery",
                 "1 leek",
                 "6C water",
                 "olive oil",
                 "salt & pepper",
                 "red chili flakes",
                 "Recipe:",
                 "Prepare the celery root. First chop off the celeri-sh stalks attached to the root and then run the root through running water for a few minutes making sure to remove as much dirt as you can. Then using your knife peel of the outer skin. Then chop the peeled celery root into small cubes.",
                 "Prepare the celery and the leek. Chop the celery sticks into small pieces. Chop the leek into small pieces and wash well (dirt gets trapped inside the leek leaves, so cleaning them after chopping is the best way to get rid of the dirt."],
        r.extract_lines
  end

  test "extract ingredients structured allrecipes com" do
    r = RecipeDocument.new(
        :url => "foo",
        :string => <<-eohtml
    <div class="ingredients" style="margin-top: 10px;">
            <h3>
                Ingredients</h3>
                    <ul>
                    <li class="plaincharacterwrap">
                        1 cup all-purpose flour</li>
                    <li class="plaincharacterwrap">
                        1 tablespoon white sugar</li>
                    <li class="plaincharacterwrap">
                        1 teaspoon baking powder</li>
                    <li class="plaincharacterwrap">
                        1/2 teaspoon baking soda</li>
                    <li class="plaincharacterwrap">
                        1/4 teaspoon salt</li>
                    <li class="plaincharacterwrap">
                        1 cup milk</li>
                    <li class="plaincharacterwrap">
                        1 egg</li>
                    <li class="plaincharacterwrap">
                        2 tablespoons vegetable oil</li>
                    </ul>
        </div>
    eohtml
    )

      assert_lines ["1 cup all-purpose flour",
       "1 tablespoon white sugar",
       "1 teaspoon baking powder",
       "1/2 teaspoon baking soda",
       "1/4 teaspoon salt",
       "1 cup milk",
       "1 egg",
       "2 tablespoons vegetable oil"], r.extract_ingredients_structured
  end


  test "extract ingredients structured epicurious com" do
    r = RecipeDocument.new(
        :url => "foo", # http://www.epicurious.com/recipes/food/views/Avocado-Goat-Cheese-Salad-with-Lime-Dressing-362911",
        :string => <<-eohtml

    <div id="ingredients">
        <div id="ingredients_headline_wrapper">
        <div id="recipeDetails_textOffer_BNA">
<a href="https://w1.buysub.com/loc/BNA/ATGFailsafeEpi" target="_blank" class="subLnk">subscribe to Bon App&eacute;tit</a>
</div>
<script type="text/javascript">
    CNP.ecom.request({
    pid:'recipeDetails_textOffer_BNA',
    tgt:'/atg/registry/RepositoryTargeters/EPI/EPI_recipeDetails_textOffer_BNA',
    params:{}});
</script>

<!--alias link is https://w1.buysub.com/loc/BNA/ba_recipe_link-->
            <h2>Ingredients</h2>
        </div>
            <ul class="ingredientsList">
                      <li class="ingredient">1 1/2 cups matchstick-size strips peeled jicama</li>
                      <li class="ingredient">1/4 cup avocado oil </li>
                      <li class="ingredient">3 tablespoons fresh lime juice </li>
                      <li class="ingredient">1 5-ounce package mixed greens </li>
                      <li class="ingredient">1 large avocado, peeled, pitted, sliced </li>
                      <li class="ingredient">1 5-ounce package soft fresh goat cheese or cotija cheese, crumbled</li>
            </ul>

    <a href="/recipes/shoppinglist/custom/Avocado-Goat-Cheese-Salad-with-Lime-Dressing-362911" target="_blank" id="printShoppingList">print a shopping list for this recipe</a>
    </div>


    eohtml
    )
    assert_lines ["1 1/2 cups matchstick-size strips peeled jicama",
                  "1/4 cup avocado oil",
                  "3 tablespoons fresh lime juice",
                  "1 5-ounce package mixed greens",
                  "1 large avocado, peeled, pitted, sliced",
                  "1 5-ounce package soft fresh goat cheese or cotija cheese, crumbled"],
                 r.extract_ingredients_structured
  end

  test "extract images from epicurious.com one" do

    r = RecipeDocument.new(
        :url => 'http://www.epicurious.com/recipes/food/views/Swiss-Chard-Lasagna-with-Ricotta-and-Mushroom-362954',
        :file => fixture_path + '/webpages/Swiss Chard Lasagna with Ricotta and Mushroom Recipe at Epicurious.com.html')
    assert_equal ["http://www.epicurious.com/images/recipesmenus/2011/2011_january/362954_116.jpg"], r.extract_images
  end

  test "extract prep from epicurious.com" do
    r = RecipeDocument.new(
            :url => 'http://www.epicurious.com/recipes/food/views/Swiss-Chard-Lasagna-with-Ricotta-and-Mushroom-362954',
            :file => fixture_path + '/webpages/Mascarpone-Filled Cake with Sherried Berries Recipe at Epicurious.com.html')
    # TODO: Obviously missing an assert.
    puts r.extract_prep_structured
  end

  test "extract lines from structured sites" do
    r = RecipeDocument.new(
            :url => 'http://www.epicurious.com/recipes/food/views/Swiss-Chard-Lasagna-with-Ricotta-and-Mushroom-362954',
            :file => fixture_path + '/webpages/Swiss Chard Lasagna with Ricotta and Mushroom Recipe at Epicurious.com.html')
    any2ingredients = ['Béchamel sauce: 2 1/2 cups whole milk', '1 Turkish bay leaf']
    puts r.extract_lines
    assert_equal any2ingredients, r.extract_lines & any2ingredients
  end

  test "comments are stripped out blogger" do
    r = RecipeDocument.newDocument(
        :url => 'http://evolvingtastes.blogspot.com/2010/11/insalata-caprese.html',
        :file => fixture_path + 'webpages/Evolving Tastes Insalata Caprese Essential.html')
    lines = r.extract_lines
    comment_lines = lines.detect { |t| t =~ /evolvingtastes said/}
    assert comment_lines.nil?, "comment line has #{comment_lines}"
  end


  test "sidebar is stripped from blogger one" do
    r = RecipeDocument.newDocument(
        :url => 'http://evolvingtastes.blogspot.com/2010/11/insalata-caprese.html',
        :file => fixture_path + 'webpages/Evolving Tastes Insalata Caprese Essential.html')
    does_not_contain(r.extract_lines, "October")
  end

  test "sidebar is stripped from blogger two" do
    r = RecipeDocument.newDocument(
            :url => 'http://mildredsrecipes.blogspot.com/2010/12/borlotti-bean-soup-with-pico-de-gallo.html',
            :file => fixture_path + 'webpages/borlotti.html')
    lines = r.extract_lines
    does_not_contain(lines, "Recipes from the kitchen of Mildreds vegetarian restaurant")
  end

  test "sidebar stripping from blogger does not remove main content" do
    r = RecipeDocument.newDocument(
            :url => 'http://mildredsrecipes.blogspot.com/2010/12/borlotti-bean-soup-with-pico-de-gallo.html',
            :file => fixture_path + 'webpages/borlotti.html')
    lines = r.extract_lines
    lines.detect {|line| line.include?("5 chopped cloves garlic")}
  end

  test "sidebar is stripped from wordpress" do
    r = RecipeDocument.newDocument(
        :url => "http://365daysveg.wordpress.com/2008/02/03/aloo-tikki/",
        :file => fixture_path + 'webpages/AlooTikki.html')
    does_not_contain(r.extract_lines, "Cucumber")
  end

  test "extract lines from myrecipes_dot_com" do
    r = RecipeDocument.new(
        :file => fixture_path + 'webpages/Eggplant Parmesan Recipe   MyRecipes.com.html',
        :url  => 'http://find.myrecipes.com/recipes/recipefinder.dyn?action=displayRecipe&recipe_id=10000000332680')
    lines = r.extract_lines
    assert !lines.detect { |t| t =~ /1  tablespoon  dried basil/}.nil?
  end

  test "extract structured foodnetwork" do
    r = RecipeDocument.new(
        :file => fixture_path + 'webpages/Chicken Kiev Recipe   Alton Brown   Food Network.html',
        :url => "http://www.foodnetwork.com/recipes/alton-brown/chicken-kiev-recipe/index.html"
    )
    assert_lines ["8 tablespoons (1 stick) unsalted butter, room temperature",
                  "1 teaspoon dried parsley",
                  "1 teaspoon dried tarragon",
                  "1 teaspoon kosher salt, plus extra for seasoning chicken",
                  "1/4 teaspoon freshly ground black pepper, plus extra for seasoning chicken",
                  "4 boneless, skinless chicken breast halves",
                  "2 large whole eggs, beaten with 1 teaspoon water",
                  "2 cups Japanese bread crumbs (panko), plus 1/4 cup for filling",
                  "Vegetable oil, for frying"], r.extract_ingredients_structured
    directions = r.extract_prep_structured
    assert_equal "Combine butter, parsley, tarragon, 1 teaspoon salt, and 1/4 teaspoon black pepper in the bowl of a stand mixer . Place mixture on plastic wrap or waxed paper and roll into small log; place in freezer.",
                directions[0]

  end

  test "extract structured food dot com" do
    r = RecipeDocument.new(
        :file => fixture_path + 'webpages/Chicken Tortilla Soup II Recipe - Food.com - 4627.html',
        :url => 'http://www.food.com/recipe/chicken-tortilla-soup-ii-4627'
    )
    assert_lines [
      "Saute carrots, onions, celery in corn oil, garlic, salt and pepper until tender.",
      "Add chicken broth and bring to boil.",
      "Add tomatoes, Rotel, taco seasoning, and chicken.",
      "Cut Tortillas into small pieces and add to broth mixture.",
      "Let boil for 20 minutes or until tortillas are thoroughly incorporated into soup stirring occasionally to keep from sticking.",
      "Reduce heat and add 8 oz. cheese. Simmer for additional 10 minutes.",
      "Add milk and simmer for additional 10 minutes.",
      "If thicker soup is desired, add more diced tortillas and let incorporate into soup.",
      "Garnish with shredded cheese and broken tortilla chips.",
      "Substitutions: 1 cup Masa Harina (Masa Flour) for 1 10 ct. package of corn tortillas. Gradually add masa flour mixing into broth, mixing thoroughly into broth. If thicker soup is desired, add more masa flour.",
      "You can also use grilled chicken fajita meat for poached diced chicken.",
    ], r.extract_prep_structured

  end

  test "extract structured recipe dot com" do
     r = RecipeDocument.new(
        :file => fixture_path + 'webpages/Company-Pleasing Crab Cakes.html',
        :url => 'http://www.recipe.com/company-pleasing-crab-cakes/'
    )
    puts r.extract_prep_structured
  end
#
#  test "extract lines removes header elements" do
#    r = RecipeDocument.newDocument(
#        :url => 'http://evolvingtastes.blogspot.com/2010/11/insalata-caprese.html',
#        :string => <<-eohtml
#        <h2 class='date-header'><span>Friday, November 12, 2010</span></h2>
#
#          <div class="date-posts">
#
#<div class='post-outer'>
#<div class='post hentry'>
#<a name='4708697586169494724'></a>
#<h3 class='post-title entry-title'>
#Insalata Caprese
#</h3>
#          eohtml
#        )
#    does_not_contain r.extract_lines, "Friday, November 12, 2010"
#  end

  private
  def does_not_contain(lines, s)
    found_lines = lines.detect { |t| t.include?(s) }
    assert found_lines.nil?, "found line #{found_lines}"
  end

end