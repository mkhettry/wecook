require 'open-uri'
# Helper class used by Recipe to parse html pages, extract ingredients etc.
class RecipeDocument

  attr :doc
  attr :title


  DEFAULT_OPTIONS = {:debug => false}

  def self.newDocument(opts={})
    RecipeDocument.new(opts)
  end

  # Either pass in a hash with :file as filename and :url as the address or
  # simply pass in a :url in which case the page is loaded from the web.
  # TODO: make this private.
  def initialize(opts={})
    @url = opts[:url]

    if opts[:file]
      s = File.open(opts[:file]).read
    elsif opts[:string]
      s=opts[:string]
    else
      s = open(opts[:url]).read
    end

    @options = DEFAULT_OPTIONS.merge(opts)

    @doc = Nokogiri::HTML(s)

    @doc.css("form, object, embed").each do |elem|
      elem.remove
    end

    # remove hardspaces &nbsp with a simple space.
    @trimmed_doc = Nokogiri::HTML(s.gsub('&nbsp;', ' '))
#    @rdoc = ReadabilityDocument.new(s, {:min_text_length => 8})
    remove_unlikely_candidates!
    remove_divs_with_high_link_density!

    @title = @doc.xpath("//title").text.lstrip.rstrip.gsub(/[\n]+/, " ")
  end

  def to_s
    @url
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

  def extract_lines
    create_lines_from_nodes(@trimmed_doc)
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

    ingredients
  end

  def extract_prep_structured
    prep_lines = []

    prep_text_nodes = @doc.xpath("//p[contains(@class, 'instructions')]")
    prep_text_nodes = @doc.xpath("//div[contains(@class, 'instructions')]/p") if prep_text_nodes.empty?
    prep_text_nodes = @doc.xpath("//div[contains(@id, 'directions')]/ol/li") if prep_text_nodes.empty?
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
      if !inside_ignorable_element(n)

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
    end
    lines << current_line if current_line != ""
    clean_lines(lines)
  end

  def split_line(node)
    node.name == 'br' || node.name == 'p' || node.name == 'div' || node.name == 'ul' ||node.name == 'li' || node.name =~ /h\d/ || node.name == 'tr'
  end

end