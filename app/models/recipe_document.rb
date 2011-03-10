require 'open-uri'
# Helper class used by Recipe to parse html pages, extract ingredients etc.
class RecipeDocument

  attr :doc
  attr :title

  def self.newDocument(opts={})
    if (opts[:url] =~ /blogspot/)
      BloggerDocument.new(opts)
    else
      RecipeDocument.new(opts)
    end
  end

  # Either pass in a hash with :file as filename and :url as the address or
  # simply pass in a :url in which case the page is loaded from the web.
  # TODO: make this private.
  def initialize(opts={})
    @url = opts[:url]

    if opts[:file]
      s = File.open(opts[:file])
    elsif opts[:string]
      s=opts[:string]
    else
      s = open(opts[:url])
    end

    @doc = Nokogiri::HTML(s)
    @title = @doc.xpath("//title").text.lstrip.rstrip.gsub(/[\n]+/, " ")
  end


  def extract_ingredients
    extract_ingredients_structured
  end

  def extract_images
    all_images = @doc.xpath('//img[@alt][contains(@src, "jpg")]')
    possible_images = {}
    all_images.each do |image|
      # Use the overlap between the 'alt' tag and the title of the post to try and guess which image
      # is most likely to be a good one. The more the overlap, the better. Skip 0 overlap images.
      inter = (image['alt'].split) & (@title.split)
      if inter.length > 0
        possible_images[image['src'].gsub(/\n/,'')] = inter.length
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
      x=possible_images.sort_by { |k,v| v}.pop(2).collect { |pair| create_absolute_url(pair[0]) }
      x
    end
  end

  def extract_lines()
#    nodes = []
#    @doc.traverse do |n|
#      nodes << n
#    end
    create_lines_from_nodes(@doc)
  end

  def create_lines_from_nodes(doc)
    lines = []
    current_line = ""

    doc.traverse do |n|
      if !inside_ignorable_element(n)

        if n.text? and not n.text.lstrip.rstrip.empty?
          #puts "appending #{n.text.lstrip.rstrip} because of #{n.name}"
          current_line = current_line + " " + n.text.lstrip.rstrip
        elsif n.name == 'br' || n.name == 'p' || n.name == 'div' || n.name == 'ul' ||n.name == 'li'

          #puts "skipping line: #{current_line} because of #{n.name}"
          lines << current_line.lstrip.rstrip if not current_line.empty?
          current_line = ""
        end
      end
    end
    lines << current_line if current_line != ""
    clean_lines(lines)
  end

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

  def is_header(n)
    n.name =~ /h\d/
  end

  def clean_lines(lines)
    lines.collect {|line| clean_text(line)}
  end

  def clean_text(s)
    # newline/tab with a space
    # nbsp with a space (http://en.wikipedia.org/wiki/Non-breaking_space) TODO: this &nbsp is not working still
    # multiple spaces with one space
    s.gsub(/[\r|\n|\t]/,' ').gsub(/\u00a0/, ' ').gsub(/\s{2,}/,' ').lstrip.rstrip
  end

  def self.print_html_structure(s)
    nodes = []
    @doc.traverse do |n|
      nodes << n
    end
    nodes
  end

  # This extractor is used to get stuff out of fairly structured recipe sites.
  # allrecipes.com,
  # TODO: food.com is problematic here.
  def extract_ingredients_structured
    ingredients = @doc.xpath("//div[contains(@class, 'ingredients')]//li").collect { |s| clean_text(s.text)}

    ingredients = @doc.xpath("//li[contains(@class,'ingredient')]").collect { |s| clean_text(s.text)} if ingredients.empty?
    ingredients = @doc.xpath("//li[contains(@itemprop,'ingredient')]").collect { |s| clean_text(s.text)} if ingredients.empty?
    ingredients = @doc.xpath("//span[contains(@class, 'ingredient')]").collect { |s| clean_text(s.text)} if ingredients.empty?

    ingredients
  end

  def extract_prep_structured
    prep_lines = []

    prep_text_nodes = @doc.xpath("//p[contains(@class, 'instructions')]")
    prep_text_nodes = @doc.xpath("//div[contains(@class, 'instructions')]/p") if prep_text_nodes.empty?
    prep_text_nodes = @doc.xpath("//li[contains(@itemprop, 'instruction')]") if prep_text_nodes.empty?

    prep_text_nodes = @doc.xpath("//span[contains(@class, 'instructions')]/ol/li/span") if prep_text_nodes.empty?
    prep_text_nodes = @doc.xpath("//span[contains(@class, 'instructions')]/div[contains(@class,'section')]") if prep_text_nodes.empty?


    prep_text_nodes.each do |p|
      new_lines = create_lines_from_nodes(p)
      next if new_lines.empty?
      prep_lines += new_lines
    end

    prep_lines
  end

  def extract_prep
    extract_prep_structured
  end

  private

  def create_absolute_url(s)
    if s.starts_with? "http"
      s
    else
      url_comps = @url.split('/')
      url_comps[0] + '//' + url_comps[2] + s
    end
  end

end