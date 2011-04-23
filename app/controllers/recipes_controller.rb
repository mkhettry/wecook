require 'nokogiri'

class RecipesController < ApplicationController

  # GET /recipes
  # GET /recipes.xml
  def index
    @recipes = Recipe.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @recipes }
    end
  end

  # GET /recipes/1
  # GET /recipes/1.xml
  def show
    @recipe = Recipe.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @recipe }
    end
  end

  # GET /recipes/new
  # GET /recipes/new.xml
  def new
    @recipe = Recipe.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @recipe }
    end
  end

  # GET /recipes/1/edit
  def edit
    @recipe = Recipe.find(params[:id])
  end

  # POST /recipes
  # POST /recipes.xml
  def create
    model = LibLinearModel.get_model
    # This should be moved to RecipeDocument
    recipe_document = RecipeDocument.new(params[:recipe])
    @recipe = Recipe.new(params[:recipe])


    @recipe.title = recipe_document.title

    predictions = model.predict_url(recipe_document)

    ingredients = recipe_document.extract_ingredients predictions
    ingredients.each do |i|
      ingredient = Ingredient.new(:raw => i)
      @recipe.ingredients << ingredient
    end

    directions = recipe_document.extract_prep(predictions)
    directions.each do |d|
      direction = Direction.new(:raw_text => d)
      @recipe.directions << direction
    end

    images = recipe_document.extract_images
    images.each do |i|
      image = Image.new(:jpg => open(i))
      @recipe.images << image
    end


    respond_to do |format|
      if @recipe.save
        format.html { redirect_to(@recipe, :notice => 'Recipe was successfully created.') }
        format.xml  { render :xml => @recipe, :status => :created, :location => @recipe }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @recipe.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /recipes/1
  # PUT /recipes/1.xml
  def update
    @recipe = Recipe.find(params[:id])

    respond_to do |format|
      if @recipe.update_attributes(params[:recipe])
        format.html { redirect_to(@recipe, :notice => 'Recipe was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @recipe.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /recipes/1
  # DELETE /recipes/1.xml
  def destroy
    @recipe = Recipe.find(params[:id])
    @recipe.destroy

    respond_to do |format|
      format.html { redirect_to(recipes_url) }
      format.xml  { head :ok }
    end
  end
end
