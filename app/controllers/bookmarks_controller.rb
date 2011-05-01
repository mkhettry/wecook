class BookmarksController < ApplicationController
  # GET /bookmarks
  # GET /bookmarks.xml
  def index
    @bookmarks = Bookmark.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bookmarks }
    end
  end

  # GET /bookmarks/1
  # GET /bookmarks/1.xml
  def show
    @bookmark = Bookmark.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @bookmark }
    end
  end

  # GET /bookmarks/new
  # GET /bookmarks/new.xml
  def new
    @recipe = Recipe.new
    @url = params[:url]
    Rails.logger.info("I am here")
    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.xml  { render :xml => @bookmark }
    end
  end

  # GET /bookmarks/1/edit
  def edit
    @bookmark = Bookmark.find(params[:id])
  end

  # POST /bookmarks
  # POST /bookmarks.xml
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
  end

  # PUT /bookmarks/1
  # PUT /bookmarks/1.xml
  def update
    @bookmark = Bookmark.find(params[:id])

    respond_to do |format|
      if @bookmark.update_attributes(params[:bookmark])
        format.html { redirect_to(@bookmark, :notice => 'Bookmark was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bookmark.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bookmarks/1
  # DELETE /bookmarks/1.xml
  def destroy
    @bookmark = Bookmark.find(params[:id])
    @bookmark.destroy

    respond_to do |format|
      format.html { redirect_to(bookmarks_url) }
      format.xml  { head :ok }
    end
  end
end
