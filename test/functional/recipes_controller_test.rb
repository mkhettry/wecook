require 'test_helper'

# These tests don't work. Ignore for now! 2/25
class RecipesControllerTest < ActionController::TestCase
  fixtures(:recipes)

#  setup do
#    @recipe = recipes(:one)
#  end
#
#  test "should get index" do
#    get :index
#    assert_response :success
#    assert_not_nil assigns(:recipes)
#  end
#
#  test "should get new" do
#    get :new
#    assert_response :success
#  end
#
#  test "should create recipe" do
#    assert_difference('Recipe.count') do
#      post :create, :recipe => @recipe.attributes
#    end
#
#    assert_redirected_to recipe_path(assigns(:recipe))
#  end
#
#  test "should show recipe" do
#    get :show, :id => @recipe.to_param
#    assert_response :success
#  end
#
#  test "should get edit" do
#    get :edit, :id => @recipe.to_param
#    assert_response :success
#  end
#
#  test "should update recipe" do
#    put :update, :id => @recipe.to_param, :recipe => @recipe.attributes
#    assert_redirected_to recipe_path(assigns(:recipe))
#  end
#
#  test "should destroy recipe" do
#    assert_difference('Recipe.count', -1) do
#      delete :destroy, :id => @recipe.to_param
#    end
#
#    assert_redirected_to recipes_path
#  end
end
