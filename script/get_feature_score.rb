require 'script/model_builder.rb'
m = ModelBuilder.build(:dir => "config/training")
fs = ModelBuilder.feature_selector
f = Feature.new("second_word_tbs")
fs.score(:IN, f)
