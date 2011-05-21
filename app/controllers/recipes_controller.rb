require 'nokogiri'

class RecipesController < ApplicationController

  # GET /recipes
  # GET /recipes.xml
  def index
    user = current_user
    if user.nil?
#      @recipes = Recipe.paginate :page=>params[:page], :order=>'created_at desc', :per_page => 10
      redirect_to welcome_path
    else
      Rails.logger.info("user id: " + user.id.to_s)
      user_recipes = UserRecipe.find_all_by_user_id(user.id)
      @recipes = user_recipes.collect{|ur| ur.recipe}.paginate :page=>params[:page], :order=>'created_at desc', :per_page => 10
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @recipes }
      end
    end
  end

  # GET /recipes/1
  # GET /recipes/1.xml
  def show
    @recipe = Recipe.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.xml  { render :xml => @recipe }
    end
  end


  def show_provisional
    @recipe = Recipe.find(params[:id])

    respond_to do |format|
      format.html
      format.js
      format.xml  { render :xml => @recipe }
    end
  end


  def submit_provisional
    @recipe = Recipe.find(params[:id])
    corrections = {}
    params[:changed].split("|").each do |change|
      next if change.empty?
      idx, category = change.split("=")
      corrections[Integer(idx)] = category
    end

    @recipe.correct!(corrections)
    @recipe.state = :ready
    respond_to do |format|
      if @recipe.save
        format.html { redirect_to(@recipe, :notice => 'Recipe was successfully corrected.') }
        format.xml  { render :xml => @recipe, :status => :created, :location => @recipe }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @recipe.errors, :status => :unprocessable_entity }
      end
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
    Rails.logger.info(" recipe_create #{params}")

    model = LibLinearModel.get_model
    recipe_document = RecipeDocument.new_document(params[:recipe])
    @recipe = recipe_document.create_recipe(model)

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
