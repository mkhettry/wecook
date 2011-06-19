#encoding: utf-8

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

  test "sfgate recipe got zero lines" do
    r = RecipeDocument.new(
        :url => "http://www.sfgate.com/food/recipes/detail.html?p=detail&rid=18199&sorig=qs",
        :file => fixture_path + '/webpages/Recipes — Cooking Ideas — Minted Cucumber-Lime Soda— SFGate Food & Wine.html')
  end

  test "easy better recipes line break" do
    r =RecipeDocument.new(
        :url => 'http://easy.betterrecipes.com/pepperoni-soup.html',
        :string => <<-eohtml
      <span class="ACThead2">Ingredients</span>
        <ul class="ingredient_list">
          <li>1 lb hamburger</li>
          <li>1/2 pkg sliced pepperoni </li>
        </ul>
      eohtml
    )

    assert_equal ["Ingredients", "1 lb hamburger", "1/2 pkg sliced pepperoni"], r.extract_lines
  end

  test "extract structured serious eats" do
    rd = RecipeDocument.new(
            :file => fixture_path + '/webpages/Serious_Eats_Belgian_Tripel.html',
            :url => 'http://www.seriouseats.com/recipes/2011/04/homebrewing-belgian-tripel-recipe.html')
    assert_lines [
        "9 pounds Pilsner malt extract",
        "1 pound light Belgian candy sugar",
        "1 pound Carapils malt, crushed",
        "2 ounces Hallertau hops - 60 minutes",
        "6 gallons of tap water, split",
        "2 Liter starter of liquid Belgian Ale yeast (Whitelabs WLP500 or Wyeast 1214)"
        ],
        rd.extract_ingredients_structured

    any_two_prep = [
        'If possible, place 3 gallons in the refrigerator to cool in a sanitized container.',
        'After primary fermentation is complete (take at least two consistent gravity readings), transfer to a secondary carboy for conditioning as discussed here and store as cool as possible.'
    ]
    assert_equal any_two_prep & rd.extract_prep_structured, any_two_prep
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

  test "extract images from epicurious com one" do

    r = RecipeDocument.new(
        :url => 'http://www.epicurious.com/recipes/food/views/Swiss-Chard-Lasagna-with-Ricotta-and-Mushroom-362954',
        :file => fixture_path + '/webpages/Swiss Chard Lasagna with Ricotta and Mushroom Recipe at Epicurious.com.html')
    images = r.extract_images
    # TODO: Image handling is not great! Not sure if we should be picking up the first image.
    assert_equal ["http://www.epicurious.com/images/articlesguides/holidays/passover/spring-navpromo-RM.jpg", "http://www.epicurious.com/images/recipesmenus/2011/2011_january/362954_116.jpg" ], images
  end

  test "deal with nbsp" do
    s = <<-eothml
      <span style="color: #FF6600;">Ingredients (use <a href="http://vegweb.com/index.php?topic=15403.0">vegan versions</a>):</span><br /><br />&nbsp; &nbsp; 14 oz. lite coconut milk<br />
    eothml
    rd = RecipeDocument.new(:url => 'http://vegweb.com/index.php?PHPSESSID=79f08cce8adba4eeba82fbe23e5a96a0&topic=12376.0',
                            :string => s)
    lines = rd.extract_lines
    one_ingredient = ['14 oz. lite coconut milk']

    assert_equal one_ingredient, one_ingredient & lines
  end

  test "deal with tables" do
    s = <<-eohtml
          <table cellspacing="0" cellpadding="0" border="0">
            <tr valign="top"><td class='ing_q'>1</td><td class='ing_uom'>tablespoon</td><td class='ing_i'><a href="/Thai/Ingredients/red_curry_paste.htm#red%20curry%20paste">red curry paste</a></td><td class='ing_opt'>&nbsp;</td></tr>
            <tr valign="top"><td class='ing_q'>3</td><td class='ing_uom'>cups</td><td class='ing_i'>water</td><td class='ing_opt'>&nbsp;</td></tr>
            <tr valign="top"><td class='ing_q'>2</td><td class='ing_uom'>tablespoons</td><td class='ing_i'>vinegar</td><td class='ing_opt'>&nbsp;</td></tr>
            <tr valign="top"><td class='ing_q'>1/3</td><td class='ing_uom'>cup</td><td class='ing_i'>tofu - extra firm, julienne</td><td class='ing_opt'>&nbsp;</td></tr>
            <tr valign="top"><td class='ing_q'>1/2</td><td class='ing_uom'>package</td><td class='ing_i'><a href="/Thai/Ingredients/Thai_rice_noodles.htm#Thai%20rice%20noodles">Thai rice noodles</a></td><td class='ing_opt'>&nbsp;</td></tr>
            <tr valign="top"><td class='ing_q'>2</td><td class='ing_uom'>tablespoons</td><td class='ing_i'>sugar</td><td class='ing_opt'>&nbsp;</td></tr>
            <tr valign="top"><td class='ing_q'>1/3</td><td class='ing_uom'>cup</td><td class='ing_i'><a href="/Thai/Ingredients/pickled_mustard.htm#pickled%20mustard">pickled mustard</a>, sliced</td><td class='ing_opt'>&nbsp;</td></tr>
            <tr valign="top"><td class='ing_q'>1</td><td class='ing_uom'></td><td class='ing_i'><a href="/Thai/Ingredients/green_onion.htm#green%20onion">green onion</a>, sliced</td><td class='ing_opt'>&nbsp;</td></tr>
            <tr valign="top"><td class='ing_q'>2</td><td class='ing_uom'>tablespoons</td><td class='ing_i'><a href="/Thai/Ingredients/fried_shallot.htm#fried%20shallot">fried shallot</a></td><td class='ing_opt'>&nbsp;</td></tr>
            <tr valign="top"><td class='ing_q'>2</td><td class='ing_uom'>tablespoons</td><td class='ing_i'><a href="/Thai/Ingredients/fish_sauce.htm#fish%20sauce">fish sauce</a></td><td class='ing_opt'>&nbsp;</td></tr>
            <tr valign="top"><td class='ing_q'>1</td><td class='ing_uom'>cup</td><td class='ing_i'><a href="/Thai/Ingredients/coconut_milk.htm#coconut%20milk">coconut milk</a></td><td class='ing_opt'>&nbsp;</td></tr>
            <tr valign="top"><td class='ing_q'>5-7</td><td class='ing_uom'>sprigs</td><td class='ing_i'><a href="/Thai/Ingredients/cilantro.htm#cilantro">cilantro</a>, sliced</td><td class='ing_opt'>&nbsp;</td></tr>
            <tr valign="top"><td class='ing_q'>1/2</td><td class='ing_uom'>lb</td><td class='ing_i'>beef</td><td class='ing_opt'>&nbsp;</td></tr>
            <tr valign="top"><td class='ing_q'>1/3</td><td class='ing_uom'>cup</td><td class='ing_i'><a href="/Thai/Ingredients/bean_sprouts.htm#bean%20sprouts">bean sprouts</a></td><td class='ing_opt'>&nbsp;</td></tr>
            <tr valign="top"><td class='ing_q'>1</td><td class='ing_uom'></td><td class='ing_i'>hard boiled egg, halved</td><td class='ing_opt'>Optional</td></tr>
          </table>
    eohtml
    r = RecipeDocument.new(
        :url => 'http://www.thaitable.com/Thai/recipes/Curried_Noodles.htm',
        :string => s
    )
    any_two_ingredients = ['1 hard boiled egg, halved Optional', '1/3 cup tofu - extra firm, julienne']
    lines = r.extract_lines
    assert_equal any_two_ingredients, any_two_ingredients & lines
  end

  test "extract prep from epicurious.com" do
    r = RecipeDocument.new(
            :url => 'http://www.epicurious.com/recipes/food/views/Swiss-Chard-Lasagna-with-Ricotta-and-Mushroom-362954',
            :file => fixture_path + '/webpages/Mascarpone-Filled Cake with Sherried Berries Recipe at Epicurious.com.html')
    # TODO: Obviously missing an assert.
    one_prep = ["Sift together flour, baking powder, baking soda, and salt."]
    assert_equal one_prep,  one_prep & r.extract_prep_structured
  end

#  test "remove link heavy divs" do
#    r = RecipeDocument.new(
#        :url => "unknown",
#        :string => <<-eohtml
#                <div class="related-keywords">
#                <h4 class="t6 b4"><a href="http://www.guardian.co.uk/lifeandstyle?INTCMP=ILCNETTXT3487">Life and style</a></h4>
#                <ul>
#                    <li><a href="http://www.guardian.co.uk/lifeandstyle/gardens?INTCMP=ILCNETTXT3487">Gardens</a> &middot; </li>
#                    <li><a href="http://www.guardian.co.uk/lifeandstyle/gardeningadvice?INTCMP=ILCNETTXT3487">Gardening advice</a> &middot; </li>
#                    <li><a href="http://www.guardian.co.uk/lifeandstyle/food-and-drink?INTCMP=ILCNETTXT3487">Food & drink</a> &middot; </li><li><a href="http://www.guardian.co.uk/lifeandstyle/salad?INTCMP=ILCNETTXT3487">Salad recipes</a> &middot; </li>
#                    <li><a href="http://www.guardian.co.uk/lifeandstyle/vegetablesrecipes?INTCMP=ILCNETTXT3487">Vegetable recipes</a> &middot; </li>
#                    <li><a href="http://www.guardian.co.uk/lifeandstyle/vegetarian?INTCMP=ILCNETTXT3487">Vegetarian recipes</a> &middot; </li>
#                    <li><a href="http://www.guardian.co.uk/lifeandstyle/freefrom?INTCMP=ILCNETTXT3487">Free from recipes</a> &middot; </li>
#                    <li><a href="http://www.guardian.co.uk/lifeandstyle/starter?INTCMP=ILCNETTXT3487">Starter recipes</a> &middot; </li><li><a href="http://www.guardian.co.uk/lifeandstyle/main-course?INTCMP=ILCNETTXT3487">Main course recipes</a></li>
#                </ul>
#            </div>
#      eohtml
#    )
#    assert_equal 0, r.extract_lines.length
#  end

  test "headers are processed correctly" do
    r = RecipeDocument.new(
        :url => "http://www.foodandwine.com/recipes/green-lentil-curry",
        :string => <<-eohtml
                        <div id='ingredients'>
                          <h3>Ingredients</h3>
                          <ol>
                            <li>1 teaspoon finely grated ginger</li>
                          </ol>
                      eohtml
    )
    assert_lines ["Ingredients", "1 teaspoon finely grated ginger"], r.extract_lines
  end


  test "extract lines from structured sites" do
    r = RecipeDocument.new(
            :url => 'http://www.epicurious.com/recipes/food/views/Swiss-Chard-Lasagna-with-Ricotta-and-Mushroom-362954',
            :file => fixture_path + '/webpages/Swiss Chard Lasagna with Ricotta and Mushroom Recipe at Epicurious.com.html')
    any2ingredients = ['2 1/2 cups whole milk', '1 Turkish bay leaf']
    assert_equal any2ingredients, r.extract_lines & any2ingredients
  end

  test "comments are stripped out blogger" do
    r = RecipeDocument.new_document(
        :url => 'http://evolvingtastes.blogspot.com/2010/11/insalata-caprese.html',
        :file => fixture_path + 'webpages/Evolving Tastes Insalata Caprese Essential.html')
    lines = r.extract_lines
    comment_lines = lines.detect { |t| t =~ /evolvingtastes said/}
    assert comment_lines.nil?, "comment line has #{comment_lines}"
  end


  test "sidebar is stripped from blogger one" do
    r = RecipeDocument.new_document(
        :url => 'http://evolvingtastes.blogspot.com/2010/11/insalata-caprese.html',
        :file => fixture_path + 'webpages/Evolving Tastes Insalata Caprese Essential.html')
    does_not_contain(r.extract_lines, "October")
  end

  test "sidebar is stripped from blogger two" do
    r = RecipeDocument.new_document(
            :url => 'http://mildredsrecipes.blogspot.com/2010/12/borlotti-bean-soup-with-pico-de-gallo.html',
            :file => fixture_path + 'webpages/borlotti.html')
    lines = r.extract_lines
    does_not_contain(lines, "Recipes from the kitchen of Mildreds vegetarian restaurant")
  end

  test "sidebar stripping from blogger does not remove main content" do
    r = RecipeDocument.new_document(
            :url => 'http://mildredsrecipes.blogspot.com/2010/12/borlotti-bean-soup-with-pico-de-gallo.html',
            :file => fixture_path + 'webpages/borlotti.html')
    lines = r.extract_lines
    lines.detect {|line| line.include?("5 chopped cloves garlic")}
  end

  test "sidebar is stripped from wordpress" do
    r = RecipeDocument.new_document(
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

  test "extract lines from nigella lawson" do
    r = RecipeDocument.new(
        :file => fixture_path + 'webpages/nigella_devils_food_cake.html',
        :url => "http://www.nigella.com/recipes/view/DEVILS-FOOD-CAKE-5310"
    )
    lines = r.extract_lines
    assert lines.detect { |line| line =~ /225g plain flour/}
  end

  # on her pages, she has a div element called "grid_3" which is just a
  # set of links (home/recipes/kitchen wisdom' etc. This should be removed because its link heavy.
  test "nigella's top grid is stripped" do
    r = RecipeDocument.new(
        :file => fixture_path + 'webpages/nigella_devils_food_cake.html',
        :url => "http://www.nigella.com/recipes/view/DEVILS-FOOD-CAKE-5310"
    )
    lines = r.extract_lines
    assert_equal nil, lines.detect { |line| line =~ /BOOKS/}
  end

  test "extract structured food dot com" do
    r = RecipeDocument.new(
        :file => fixture_path + 'webpages/Chicken Tortilla Soup II Recipe - Food.com - 4627.html',
        :url => 'http://www.food.com/recipe/chicken-tortilla-soup-ii-4627'
    )
    prep = r.extract_prep_structured
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
    ], prep

  end

  test "extract structured recipe dot com" do
     r = RecipeDocument.new(
        :file => fixture_path + 'webpages/Company-Pleasing Crab Cakes.html',
        :url => 'http://www.recipe.com/company-pleasing-crab-cakes/'
    )
    prep =  r.extract_prep_structured
    assert_equal 'In a large skillet, melt 2 tablespoons of the butter or margarine over medium-high heat. Add sweet pepper, celery, and onion. Cook and stir about 5 minutes or until tender, but not brown.',
                 prep[0]
  end

  test "extract structured all recipes" do
    r = RecipeDocument.new(
        :url => 'http://allrecipes.com/Recipe/Ricotta-Stuffed-Zucchini/Detail.aspx',
        :file => fixture_path + 'webpages/Ricotta Stuffed Zucchini Recipe - Allrecipes.com.html')
    first_last_ingredients = ['2 zucchini, halved lengthwise', '1/2 teaspoon ground black pepper']
    assert_equal first_last_ingredients, first_last_ingredients & r.extract_ingredients_structured

    first_last_prep = ['Preheat oven to 450 degrees F (230 degrees C). Grease a baking sheet.',
                       'Bake in preheated oven until zucchini is tender and filling is beginning to brown, 15 to 20 minutes.']
    assert_equal first_last_prep, first_last_prep & r.extract_prep_structured
  end


  test "extract_prep_structured removes numbering of directions at the beginning" do
    r = RecipeDocument.new(
        :url => "foo",
        :string => <<-eohtml
    <div class="instructions" style="margin-top: 10px;">
            <h3>
                Directions</h3>
                    <p> 1. normal prep </p>
                    <p> 2. prep with 1. a number </p>
                    <p> 3. 5 minutes of heating - prep with number, but not a prep-number </p>
                    <p> 4) prep with number-paran </p>
                    <p> 10. two digit prep</p>
                    <p> 11) two digit prep-paran</p>
        </div>
    eohtml
    )
    assert_lines ["normal prep",
                  "prep with 1. a number",
                  "5 minutes of heating - prep with number, but not a prep-number",
                  "prep with number-paran",
                  "two digit prep",
                  "two digit prep-paran"],
                 r.extract_prep_structured
  end


  test "extract_lines_for_category removes numbering at start for PR category" do
    r = RecipeDocument.new(
        :url => "foo",
        :string => <<-eohtml
    <div class="something" style="margin-top: 10px;">
                    <p> 1. normal prep </p>
                    <p> 2. prep with 1. a number </p>
                    <p> 3. 5 minutes of heating - prep with number, but not a prep-number </p>
                    <p> 4) prep with number-paran </p>
                    <p> 10. two digit prep</p>
                    <p> 11) two digit prep-paran</p>
        </div>
    eohtml
    )
    predictions = []
    predictions << LibLinearModel::Prediction.new(:map => {:PR => 1.0, :OT => 0.0})
    predictions << LibLinearModel::Prediction.new(:map => {:PR => 1.0, :OT => 0.0})
    predictions << LibLinearModel::Prediction.new(:map => {:PR => 1.0, :OT => 0.0})
    predictions << LibLinearModel::Prediction.new(:map => {:PR => 1.0, :OT => 0.0})
    predictions << LibLinearModel::Prediction.new(:map => {:PR => 1.0, :OT => 0.0})
    predictions << LibLinearModel::Prediction.new(:map => {:PR => 1.0, :OT => 0.0})

    assert_lines ["normal prep",
                  "prep with 1. a number",
                  "5 minutes of heating - prep with number, but not a prep-number",
                  "prep with number-paran",
                  "two digit prep",
                  "two digit prep-paran"],
                 r.extract_lines_for_category(predictions, :PR)
  end


  test "extract_lines_for_category does not remove numbering unless PR category" do
    r = RecipeDocument.new(
        :url => "foo",
        :string => <<-eohtml
    <div class="something" style="margin-top: 10px;">
                    <p> 1. ingredient </p>
                    <p> 2. prep </p>
        </div>
    eohtml
    )
    predictions = []
    predictions << LibLinearModel::Prediction.new(:map => {:IN => 1.0, :OT => 0.0})
    predictions << LibLinearModel::Prediction.new(:map => {:PR => 1.0, :OT => 0.0})

    assert_lines ["1. ingredient"], r.extract_lines_for_category(predictions, :IN)
  end

  test "check opts are modified for foodbuzz" do
    opts = RecipeDocument.redirect_if_needed(
              :url => 'http://www.foodbuzz.com/blogs/3623585-triple-berry-orange-glazed-shortbread',
              :file => fixture_path + 'webpages/foodbuzz-triple-berry.html')
    assert_equal('http://www.sprinkledwithflour.com/2011/05/triple-berry-orange-shortbread.html', opts[:url])
    assert_equal [:url], opts.keys
  end

  test "create recipe for structured document" do
    r = RecipeDocument.new(
        :url => 'http://www.epicurious.com/recipes/food/views/Swiss-Chard-Lasagna-with-Ricotta-and-Mushroom-362954',
        :file => fixture_path + '/webpages/Swiss Chard Lasagna with Ricotta and Mushroom Recipe at Epicurious.com.html')
    recipe = r.create_recipe(nil)
    puts recipe.ingredients[0].ordinal
    prev = -1
    recipe.ingredients.all? do |ingredient|
      assert prev+1 == ingredient[:ordinal], "#{ingredient.raw} should have had ordinal #{prev+1}"
      prev = ingredient[:ordinal]
    end
  end

  private
  def does_not_contain(lines, s)
    found_lines = lines.detect { |t| t.include?(s) }
    assert found_lines.nil?, "found line #{found_lines}"
  end

end