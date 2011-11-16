require 'open-uri'
# Helper class used by Recipe to parse html pages, extract ingredients etc.
class RecipeDocument

  attr :doc
  attr :title
  attr :trimmed_doc

  DEFAULT_OPTIONS = {:debug => false, :min_lines_for_document => 10}

  def self.new_document(opts={})
    RecipeDocument.new(redirect_if_needed(opts))
  end

  def self.redirect_if_needed(opts)
    url = opts[:url].strip
    if (url =~ /foodbuzz.com|gojee\.com/)
      doc = Nokogiri::HTML(read_document(opts))
      iframe = doc.css('iframe')
      return :url => iframe[0]['src'] if iframe and iframe[0]
    elsif (url =~ /file:\/\//)
      # this path is only used by integration tests. The format for passing in files is
      # file://spec/fixtures/webpages/evolving_tastes.html#http://evolvingtastes.blogspotcom/2009/12/shevayachi-kheer.html
      # the file path is a relative path from the project root.
      file_path, actual_url = url.split("#")
      opts[:file] = file_path.gsub("file://", "")
      opts[:url] = actual_url
    end
    opts
  end

  def self.read_document(opts)
    if opts[:file]
      s = File.open(opts[:file]).read
    elsif opts[:string]
      s=opts[:string]
    else
      s = open(opts[:url].strip).read
    end
    s
  end

  # Either pass in a hash with :file as filename and :url as the address or
  # simply pass in a :url in which case the page is loaded from the web.
  # TODO: make this private.
  def initialize(opts={})
    @url = opts[:url].strip

    s = RecipeDocument.read_document(opts)

    @options = DEFAULT_OPTIONS.merge(opts)
    # remove hardspaces &nbsp with a simple space.
    s.gsub!('&nbsp;', ' ')
    @doc = Nokogiri::HTML(s)


    @trimmed_doc = Nokogiri::HTML(s)

    @trimmed_doc.css("object, embed").each do |elem|
      elem.remove
    end

    remove_unlikely_candidates!
    remove_divs_with_high_link_density!

    @title = @doc.xpath("//title").text.lstrip.rstrip.gsub(/[\n]+/, " ")
  end

  def create_recipe(model)
    recipe = Recipe.new()
    recipe.url = @url

    recipe.title = @title
    recipe.structured = is_structured?
    if (recipe.structured?)
      recipe.state = :ready
      ingredients = extract_ingredients_structured
      ingredients.each_with_index do |txt, i|
        ingredient = Ingredient.new(:raw_text => txt, :ordinal => i)
        recipe.ingredients << ingredient
      end

      directions = extract_prep_structured
      directions.each do |d|
        direction = Direction.new(:raw_text => d)
        recipe.directions << direction
      end
    else
      h = model.predict_url(self)
      lines = h[:lines]
      predictions = h[:predictions]
      line_to_output = ""
      lines.each_index do |idx|
        line_to_output += predictions[idx].top_class.to_s + "\t" + lines[idx] + "\n"
      end
      recipe.page = line_to_output
      recipe.state = :provisional
    end

    images = extract_images
    images.each do |image_url|
      image = Image.new(:jpg => open(image_url))
      recipe.images << image
    end
    recipe
  end
  
  def to_s
    @url
  end

  def extract_images(num_images=2)
    all_images = @trimmed_doc.xpath('//img')
    all_images = @doc.xpath("//img") if all_images.empty?
    possible_images = {}
    all_images.each do |image|
      next unless image['src'].downcase =~ /jpg|jpeg/
      image_score = calculate_image_score(image)
      if image_score >= 0
        possible_images[image['src'].gsub(/\n/,'').gsub(/\\/, "/")] = image_score
      end
    end

    if (possible_images.empty?)
      possible_images
    else
      # man, this is a terse but readable (?) language.
      # First sort the map by values, this yields array of pairs.
      # then take the last two elements in the pair and then throw away
      # the value, retaining the key. Then prepend domain name if its a
      # relative path.
      x=possible_images.sort_by { |k,v| v}.pop(num_images).collect { |pair| create_absolute_url(pair[0]) }
      x
    end
  end

  def extract_lines
    @lines ||= create_lines_from_nodes(@trimmed_doc)
    if (@lines.length < @options[:min_lines_for_document])
      @lines = create_lines_from_nodes(@doc)
    end
    @lines
  end

  def is_structured?
    (not extract_ingredients_structured.empty?) and (not extract_prep_structured.empty?)
  end

  # This extractor is used to get stuff out of fairly structured recipe sites.
  # allrecipes.com,
  # TODO: food.com is problematic here.
  def extract_ingredients_structured
    ingredients = @doc.xpath("//div[contains(@class, 'ingredients')]//li").collect { |s| clean_text(s.text)}
    ingredients = @doc.xpath("//div[contains(@id, 'ingredients')]//li").collect { |s| clean_text(s.text)} if ingredients.empty?

    ingredients = @doc.xpath("//li[contains(@class,'ingredient')]").collect { |s| clean_text(s.text)} if ingredients.empty?
    ingredients = @doc.xpath("//li[contains(@itemprop,'ingredient')]").collect { |s| clean_text(s.text)} if ingredients.empty?
    ingredients = @doc.xpath("//span[contains(@class, 'ingredient')]").collect { |s| clean_text(s.text)} if ingredients.empty?
    ingredients = @doc.css("div.ingredients-section li").collect { |s| clean_text(s.text)} if ingredients.empty?

    ingredients
  end

  def extract_prep_structured
    prep_lines = []

    prep_text_nodes = @doc.xpath("//div[@class = 'directions']/ol/li")
    prep_text_nodes = @doc.xpath("//p[contains(@class, 'instructions')]") if prep_text_nodes.empty?
    prep_text_nodes = @doc.xpath("//div[contains(@class, 'instructions')]/p") if prep_text_nodes.empty?
    prep_text_nodes = @doc.xpath("//div[contains(@id, 'directions')]/ol/li") if prep_text_nodes.empty?
    prep_text_nodes = @doc.xpath("//li[contains(@itemprop, 'instruction')]") if prep_text_nodes.empty?

    prep_text_nodes = @doc.xpath("//span[contains(@class, 'instructions')]/ol/li/span") if prep_text_nodes.empty?
    prep_text_nodes = @doc.xpath("//span[contains(@class, 'instructions')]/div[contains(@class,'section')]") if prep_text_nodes.empty?

    prep_text_nodes = @doc.css("div.procedure-text p") if prep_text_nodes.empty?

    prep_text_nodes.each do |p|
      new_lines = create_lines_from_nodes(p)
      next if new_lines.empty?
      new_lines.each do |line|
        prep_lines << remove_start_numbering(line)
      end
    end

    prep_lines
  end


  private
  def ignorable_element(n)
    # widget profile/label/blogarchive are blogger widgets on the sidebar. they are not
    # the main content and often the food tags that bloggers put there tend to confuse the
    # classifier
    # widget-area tends to be the way wordpress does it
    return true if n['class'] =~ /comment|sidebar section|post-footer|entry-utility|widget Profile|widget Label|widget BlogArchive|tweets|twitter|widget-area/


    return true if n['id'] =~ /header|footer|nav/

    # tweet area
    return true if n['id'] =~ /tweets/

    # generally get rid of headers and title. they confuse the classifier.
    # return true if is_header(n)

    return true if n.name == 'title'

    false
  end


  #image is a Nokogiri document element
  def calculate_image_score(image)
    alt_score = calculate_alt_score(image)
    return alt_score if alt_score < 0

    img_dim_score = calculate_img_dim_score(image)
    return img_dim_score if img_dim_score < 0

    img_dim_score + alt_score
  end

  def calculate_alt_score(image)
    return 0 unless image['alt']

    # Use the overlap between the 'alt' tag and the title of the post to try and guess which image
    # is most likely to be a good one. The more the overlap, the better. Skip 0 overlap images.
    alt_words = (image['alt'].downcase.split)
    title_words = @title.downcase.split
    min_words = [alt_words.length,title_words.length].min.to_f
    min_words > 0 ? (alt_words & title_words).length/min_words : 0
  end

  def calculate_img_dim_score(image)
    return 0 if image['width'].nil? || image['height'].nil?

    width = get_image_size(image['width'])
    height = get_image_size(image['height'])
    return 0 if width == 0 || height == 0

    score = height > width ? width/height.to_f : height/width.to_f
    score > 0.3 ? score : -1 #for weeding out banner ads or skewed images
  end

  def get_image_size(size_string)
    (size_string.gsub("px","").to_i) rescue 0
  end

  def remove_start_numbering(line)
    line.sub(/^\d+[\.\)]/,"").strip
  end

  def is_header(n)
    n.name =~ /h\d/
  end

  def clean_lines(lines)
    lines.collect {|line| clean_text(line)}
  end

  def clean_text(s)
    # newline/tab with a space
    # multiple spaces with one space
    s.gsub(/[\r|\n|\t]/,' ').gsub(/\s{2,}/,' ').strip
  end

  def self.print_html_structure(s)
    nodes = []
    @doc.traverse do |n|
      nodes << n
    end
    nodes
  end

  # TODO: This can be thrown away. Possibly. This work is now done by remove_unlikely_candidates!
  def inside_ignorable_element(n)
    while not n.kind_of? Nokogiri::HTML::Document and n.kind_of? Nokogiri::XML::Node and n.parent() != nil
      if ignorable_element(n)
        return true
      else
        n = n.parent
      end
    end
    false
  end

  def create_absolute_url(s)
    if s.starts_with? "http"
      s
    else
      url_comps = @url.split('/')
      url_comps[0] + '//' + url_comps[2] + s
    end
  end

  def node_name(elem)
    "#{elem[:class]}#{elem[:id]}"
  end

  def remove_unlikely_candidates!
    # this was the original from readability.
    # unlikely = /combx|comment|community|disqus|extra|foot|header|menu|remark|rss|shoutbox|sidebar|sponsor|ad-break|agegate|pagination|pager|popup/i
    unlikely = /combx|comment|community|disqus|extra|foot|header|menu|remark|rss|shoutbox|sidebar|sponsor|ad-break|agegate|pagination|popup/i
    likely = /and|article|body|column|main|shadow/i

    @trimmed_doc.css("*").each do |elem|
      str = node_name(elem)
      if str =~ unlikely && str !~ likely && elem.name.downcase != 'body'
        debug("Removing unlikely candidate - #{str}")
        elem.remove
      end
    end

    @trimmed_doc.css("script, style").each { |i| i.remove }

  end

  def remove_divs_with_high_link_density!

    @trimmed_doc.xpath("//div").each do |div|
      div_name = node_name(div)
      if (remove_node(div))
        div.remove
      end
    end
  end

  def remove_node(node)
    density = get_link_density(node)
    node_length = get_text_length(node)

    remove = density > 0.6 or (density> 0.3 and node_length <256)
    remove
  end

  def get_text_length(node)
    node.text.squeeze.strip.length
  end


  def get_link_density(node)
    link_length = node.css("a").map {|i| i.text}.join("").length
    text_length = node.text.squeeze.strip.length

    #puts "#{text_length}--#{link_length}"
    1.0 if text_length == 0 and link_length > 0
    link_length / Float(text_length)
  end

  def debug(i)
    puts i if @options[:debug]
  end



  def create_lines_from_nodes(doc)
    lines = []
    current_line = ""

    doc.traverse do |n|
#      next if inside_ignorable_element(n)
#      puts "#{n.name}--#{n.next_sibling.name if n.next_sibling}"
#      if (n.text?)
#        puts "#{n.text.lstrip.rstrip.empty?}"
#      end

      if n.text? and not n.text.lstrip.rstrip.empty?
        #puts "appending #{n.text.lstrip.rstrip} because of #{n.name}"
        current_line = current_line + " " + n.text.lstrip.rstrip
      elsif split_line(n)

        #puts "skipping line: #{current_line} because of #{n.name}"
        clean_text = clean_text current_line
        lines << clean_text if not clean_text.empty?
        current_line = ""
      end
    end
    lines << current_line if current_line != ""
    clean_lines(lines)
  end

  def split_line(node)
    node.name == 'br' ||
        node.name == 'p' ||
        node.name == 'div' ||
        node.name == 'ul' ||
        node.name == 'li' ||
        node.name =~ /h\d/ ||
        node.name == 'tr' ||
        node.next_sibling.name == 'ul' if node.next_sibling ||
        node.next_sibling.name == 'ol' if node.next_sibling


  end

end