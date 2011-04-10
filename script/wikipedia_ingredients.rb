require 'open-uri'

cmlimit = 10000

def construct_url(category)
  category.gsub!(" ", "_")
  "http://en.wikipedia.org/w/api.php?action=query&list=categorymembers&cmtitle=#{category}&cmlimit=500&format=xml"
end


def get_contents_for_category(category)
  url = construct_url(category)
  page = open(url, "User-Agent" => "ruby")
  data = page.read
  doc = Nokogiri::HTML(data)
  doc.xpath("//cm").collect{|e| e['title']}
end


categories = ["Category:Herbs","Category:Spices", "Category:Leaf vegetables","Category:Root vegetables", "Category:Edible legumes", "Category:Stem vegetables", "Category:Fruit vegetables", "Category:Sea vegetables", "Category:Inflorescence vegetables", "Category:Vegetable oils"]
titles = []

while(!categories.empty?)
  category = categories.pop
  current_titles = get_contents_for_category(category)
  puts "working on category: #{category}, found:#{current_titles.length}, remaining: #{categories.length}"
  current_titles.each do |title|
    titles << title unless title =~ /^Category:/
  end
end

titles.each do |title|
  puts title
end

