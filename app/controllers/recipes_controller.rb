require 'nokogiri'

class RecipesController < ApplicationController

  before_filter :require_login

  # GET /recipes
  # GET /recipes.xml
  def index
    user = current_user
    Rails.logger.info("user id: " + user.id.to_s)
    query_hash = {:per_page => 10, :page => params[:page], :order => "created_at desc"}
    if (params[:p] == "all")
      query_hash[:joins] = :recipe
      query_hash[:conditions] = ["user_id != ? and recipes.state = ?", user.id, :ready]
    else
      query_hash[:conditions] = ['user_id = ?', user.id]
    end
    @user_recipes = UserRecipe.paginate query_hash
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_recipes }
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
    @show = current_user.needs_prov_help
    respond_to do |format|
      format.html
      format.js
      format.xml  { render :xml => @recipe }
    end
  end


  def submit_provisional
    @recipe = Recipe.find(params[:id])
    user = current_user
    if params.has_key?(:user_help) && !params[:user_help].empty?
      user.needs_prov_help = false
      user.save
    end

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
        format.html { redirect_to(recipes_url, :notice => 'Recipe was successfully corrected.') }
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
    user_recipe = UserRecipe.create(params[:recipe][:url], current_user)

    respond_to do |format|
      if user_recipe.save
        format.html { redirect_to recipes_path }
        format.xml  { render :xml => user_recipe, :status => :created, :location => user_recipe }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => user_recipe.errors, :status => :unprocessable_entity }
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

  def archive
    @user_recipe = UserRecipe.find(params[:id])
    @user_recipe.destroy
    respond_to do |format|
      format.html {redirect_to recipes_url, :notice => "Archived Recipe"}
      format.xml {head :ok}
      format.js
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
