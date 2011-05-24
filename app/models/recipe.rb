require 'open-uri'

class Recipe < ActiveRecord::Base
  has_many :ingredients, :order => "ordinal"
  has_many :images
  has_many :directions

  attr :lines

  def to_s
    "url=#{url}"
  end

  def site_source
    url.split('/')[2].gsub('www.', '')
  end

  def is_ready?
    self[:state].intern == :ready
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

  def correct!(corrections)
    Rails.logger.debug("got corrections with: " + corrections.to_s)
    in_idx = 0
    get_lines_with_prediction.each_with_index do |map, idx|
      if corrections.has_key?(idx)
        prediction = corrections[idx].downcase
        Rails.logger.debug("Using corrected prediction " + prediction + " for id: " + idx.to_s)
      else
        prediction = map[:class].downcase
      end
      next if prediction == "ot"

      line = map[:line]
      if (prediction == "in")
        self.ingredients << Ingredient.new(:raw => line, :ordinal => in_idx)
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

  def sample_image()
    if images.empty?
      'rails.png'
    else
      images.sample.jpg.url
    end
  end

end
