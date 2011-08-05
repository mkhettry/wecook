class UserRecipe < ActiveRecord::Base

  cattr_reader :per_page
  @@per_page = 10
  belongs_to :user
  belongs_to :recipe
  acts_as_taggable


  def self.create(url, user)
    recipe = Recipe.get_or_create_recipe(url)
    if (recipe.persisted?)
      ur = UserRecipe.first :include => :recipe, :conditions => {:user_id => user, :recipes => {:url => url}}
    end
    ur ||= UserRecipe.new :recipe => recipe, :user => user
    ur
  end

  def self.find_by_url_and_user(url, user)
    UserRecipe.all :conditions => {:user_id => user, :user_id =>user}
  end

  def self.find_page_for_user(opts, user_id)
    opts[:conditions] = ['user_id = ?', user_id]
    UserRecipe.paginate opts
  end

end
