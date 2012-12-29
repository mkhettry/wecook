class BookmarksController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :allow_cross_domain_access, :only => [:create, :new]
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
    Rails.logger.info("bookmarks#new")
    Rails.logger.info("session is #{session}")
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
    user = User.find(params[:user_id])
    user_recipe = UserRecipe.create(params[:foobar], user)
    Rails.logger.info("Got this recipe: " + user_recipe.recipe.url)
    # TODO: error handling?
    user_recipe.save
    respond_to do |format|
      format.json do
        render :json => "['a']"
      end
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

  private
  def allow_cross_domain_access
    response.headers["Access-Control-Allow-Origin"] = "*"
  end
end
