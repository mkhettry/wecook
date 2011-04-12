require 'open-uri'

if ARGV.length != 1
  puts "Must specify a top level URL"
  exit -1
end



doc = Nokogiri::HTML(open(ARGV[0]))
links=doc.xpath('//a[contains(@href, "recipes/food")]')
urls=links.collect {|l| "http://epicurious.com/" + l.attribute('href').to_s}.uniq
urls.each do |url|
#  next unless url =~ /\/\d+/

  rd = RecipeDocument.new(:url => url)
  ingredients = rd.extract_ingredients_structured
  prep = rd.extract_prep_structured

  name = "config/training/" +  url.split("/")[2].gsub(".", "_") + "_" + url.hash.abs.to_s + ".trs"
  next if (File.exists?(name))

  f = File.open(name, 'w')
  f.puts('#' + url)

  ingredients.each do |ing|
    f.write("IN\t")
    f.puts(ing)
  end

  prep.each do |p|
    f.write("PR\t")
    f.puts(p)
  end

  puts "#{url}"
end
