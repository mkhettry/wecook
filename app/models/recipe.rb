require 'open-uri'

class Recipe < ActiveRecord::Base
  has_many :ingredients, :order => "ordinal"
  has_many :images
  has_many :directions

  attr :lines

  def self.get_or_create_recipe(url)
    r = Recipe.find_by_url(url)
    return r if r

    model = LibLinearModel.get_model
    recipe_document = RecipeDocument.new_document(:url => url)
    recipe_document.create_recipe(model)
  end

  def editable?
    !structured?
  end

  def to_s
    "url=#{url}"
  end

  def site_source
    url.split('/')[2].gsub('www.', '')
  end

  def is_ready?
    self[:state].intern == :ready
  end

  def get_lines_with_corrected_prediction(correction_string)
    out = []
    corrections = corrections_to_hash(correction_string)

    get_lines_with_prediction.each_with_index do |map, idx|
      if corrections.has_key?(idx)
        prediction = corrections[idx].downcase
        Rails.logger.debug("Using corrected prediction " + prediction + " for id: " + idx.to_s)
      else
        prediction = map[:class].downcase
      end
      out << {:class => prediction, :line => map[:line]}
    end
    out
  end

  def correct!(correction_string)
    Rails.logger.debug("Got correction string: " + correction_string)

    self.ingredients.clear
    self.directions.clear
    self.corrections = "" if self.corrections.nil?
    self.corrections += "|" + correction_string
    self.state = :ready

    Rails.logger.debug("got corrections with: " + self.corrections)
    in_idx = 0
    get_lines_with_corrected_prediction(self.corrections).each do |map|
      line = map[:line]
      prediction = map[:class]
      next if prediction == "ot"

      if (prediction == "in")
        self.ingredients << Ingredient.new(:raw_text => line, :ordinal => in_idx)
        in_idx += 1
      elsif (prediction == "pr")
        self.directions << Direction.new(:raw_text => line)
      end
    end
  end

  def extract_lines_internal(doc)
    l2 = []
    current_line = ""
    doc.traverse do |n|
      if n.text?
        current_line = current_line + n.text
      elsif n.name == 'br' || n.name == 'p' || n.name = 'span'
        l2 << current_line.lstrip.rstrip
        current_line = ""
      end
    end
    l2
  end

  def extract_lines_from_url()
    doc = Nokogiri::HTML(open(self[:url]))

    @lines = extract_lines_internal(doc)
  end

  def sample_image(style=:thumb)
    if images.empty?
      'chopstick.jpeg'
    else
      image = images.sample
      image.has_styles ? image.jpg.url(style) : image.jpg.url
    end
  end

  private

  def corrections_to_hash(correction_string)
    corrections = {}
    return corrections if correction_string.nil?

    correction_string.split("|").each do |change|
      next if change.empty?
      idx, category = change.split("=")
      corrections[Integer(idx)] = category
    end
    corrections
  end

  def get_lines_with_prediction
    out = []
    self[:page].split("\n").each do |line|
      parts = line.split("\t")
      category = parts[0].downcase
      category = "ot" unless category == "in" or category == "pr"
      out << {:class => category, :line => parts[1]}
    end
    out
  end

end
