# Goes through each recipe in the database and spits ot a line
recipes = Recipe.all
recipes.each do |r|
  rd = RecipeDocument.new(:url => r[:url])
  puts rd.lines
end
  
