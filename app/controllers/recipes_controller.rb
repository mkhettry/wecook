require 'nokogiri'

class RecipesController < ApplicationController

  # GET /recipes
  # GET /recipes.xml
  def index
    user = current_user
    query_hash = {:page => params[:page], :order => "updated_at desc", :per_page => UserRecipe.per_page}
    if (user.nil?)
      query_hash[:joins] = :recipe
      query_hash[:conditions] = ["recipes.state = ?", :ready]
      query_hash[:per_page] = UserRecipe.per_page
      @user_recipes = UserRecipe.paginate query_hash
    elsif (params[:p] == "all")
      query_hash[:joins] = :recipe
      query_hash[:conditions] = ["user_id != ? and recipes.state = ?", user.id, :ready]
      query_hash[:per_page] = UserRecipe.per_page
      @user_recipes = UserRecipe.paginate query_hash
    else
      tags = params[:tag]
      if (tags)
        @user_recipes = UserRecipe.tagged_with(tags).where('user_id=?', user.id).paginate query_hash
      else
        @user_recipes = UserRecipe.find_page_for_user(query_hash, user.id)
      end
    end
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

    @recipe.correct!(params[:changed])

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

  def add_tag
    ur = UserRecipe.find(params[:id])
    tag = params[:tag].strip
    added = false
    if (not ur.tag_list.include?(tag))
      added = true
      ur.tag_list << tag
    end

    respond_to do |format|
      if ur.save
        Rails.logger.debug "Added tag: " + params[:tag]
        format.json {render :status => 200, :json => "{\"added\": #{added}}"}
      else
        format.json {render :status => 500, :nothing => true}
      end
    end
  end

  def delete_tag
    ur = UserRecipe.find(params[:id])
    tag_to_delete = params[:tag]
    ur.tag_list.delete(tag_to_delete)
    Rails.logger.debug "deleted tag: " + tag_to_delete
    respond_to do |format|
      if ur.save
        format.json {render :status => 200, :nothing => true}
      else
        format.json {render :status => 500, :nothing => true}
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

  # TODO: can this go away?
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
