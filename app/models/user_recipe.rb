class UserRecipe < ActiveRecord::Base

  belongs_to :user
  belongs_to :recipe


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
end
