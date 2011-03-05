urls = File.open('config/training_urls.txt', 'r') do |file|
  i=0
  file.each_line do |url|
    next if url.lstrip.rstrip.empty?

    i = i + 1
    puts "working on #{url}"
    rd = RecipeDocument.newDocument(:url => url)
    content_div = rd.doc.xpath("//div[@id='content']")
    if (content_div)
      puts "Found content div for #{url}"
    end
  end
end