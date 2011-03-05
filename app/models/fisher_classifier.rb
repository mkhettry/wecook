class FisherClassifier < Classifier
  def cprob(f, cat)
    clf = fprob(f, cat)
    return 0 if clf == 0

    freqsum = 0.0

    categories().each do |c|
      freqsum += fprob(f,c)
    end

    clf / freqsum
  end

#  TODO:Later, we need to make weigted probability take a probability function first!
#  def fisher_probability(item, cat)
#    p=1
#    features = @getfeatures.call(item)
#    features.each do |f|
#      p *= weighted_probability
#    end
#  end
end