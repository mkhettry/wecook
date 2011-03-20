class LibLinearModelWeight

  attr_reader :feature_id, :class_id, :weight_value

  def initialize(feature_id, class_id, weight_value)
    @feature_id = Integer(feature_id)
    @class_id = Integer(class_id)
    @weight_value = Float(weight_value)
  end

end