module RecipesHelper

  CATEGORY_MAP = {:Ingredients => "in", :Directions => "pr", :Other => "ot"}
  REVERSE_CATEGORY_MAP = {"in" => "Ingredient", "pr" => "Direction", "ot" => "Other"}

  def get_class_for_inline_recipe(recipe)
    if recipe.is_ready?
      "recipeline"
    else
      "recipeline recipe_provisional"
    end
  end

  def get_title_link(recipe)
    if recipe.is_ready?
      link_to recipe.title, recipe, :remote => true
    else
      link_to recipe.title, show_provisional_recipe_path(recipe)
    end
  end

  def get_user_display_name
    user = current_user
    if user
      user.name ? user.name : user.email
    end
  end

  def get_image(recipe)
    if (recipe.is_ready?)
      image_tag(recipe.sample_image(:medium), :size => "260x180", :"data-toggle" => "modal",
         :"data-target" => "#recipe_" + recipe.id.to_s)
    else
      link_to(image_tag(recipe.sample_image(:medium), :size => "260x180"),
              show_provisional_recipe_path(recipe))
    end
  end

  def time_string(date)
    recipe_save_time = date.localtime
    day_number = Time.now.yday
    if (recipe_save_time.yday == day_number)
      "Today"
    elsif (day_number - date.yday == 1)
      "Yesterday"
    else
      recipe_save_time.strftime("%b %d, %Y")
    end
  end

  def my_recipe(user_recipe, params_p)
    user_recipe.user == current_user
  end

  def remove_tag(url, new_tag)
    query_hash, uri = get_query_hash(url)


    tags = remove_tags_from_uri(query_hash)
    tags.delete(new_tag)

    query_hash['tag'] = tags.join(',') unless tags.empty?
    query_hash.delete 'page' # we want to hit the recipes controller starting with page=0

    # CGI puts every query param in array and to_query turns it into a param with a []!
    nqh = {}
    query_hash.each_pair { |k, v| nqh[k] = v.length == 1 ? v[0] : v}

    uri.query = nqh.to_query
    uri.to_s
  end

  def get_tags(url)
    query_hash, uri = get_query_hash(url)
    return query_hash["tag"][0].split(",") if query_hash.has_key? 'tag'
    []
  end

  def remove_start_numbering(line)
    line.sub(/^\d+[\.\)]/,"")
  end

  private
  def get_query_hash(url)
    uri = URI::parse(url)

    query_hash = {}
    query_hash = CGI::parse(CGI::unescape(uri.query)) unless uri.query.nil?
    return query_hash, uri
  end

  def remove_tags_from_uri(query_hash)
    tags = query_hash.delete("tag")

    if tags.nil?
      []
    else
      tags[0].split(",")
    end
  end
end
