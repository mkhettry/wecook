require 'open-uri'

class Recipe < ActiveRecord::Base
  has_many :ingredients
  has_many :images

  attr :lines

  def to_s
    "url=#{url}"
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
