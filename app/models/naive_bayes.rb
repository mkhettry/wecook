class NaiveBayes < Classifier
  def docprob(item, cat)
      features = @getfeatures.call(item)
      p = 1
      features.each do |f|
        wp = weighted_probability(f, cat)
        RAILS_DEFAULT_LOGGER.debug "#{f.join(",")} for #{cat} is #{wp}"
        p *= wp
      end
      RAILS_DEFAULT_LOGGER.debug "weighted probability for #{cat} is #{p}"
      p
    end

  def prob(item, cat)
    catprob = catcount(cat) / totalcount()
    docprob = docprob(item, cat)

    #puts "cat=#{cat}, catprob=#{catprob}, docprob=#{docprob}"

    docprob * catprob
  end

end