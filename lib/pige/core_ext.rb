class Array

  def before(before)
    if before
      reverse.select { |r| r.before?(before) }
    else
      reverse
    end
  end

  def first_value(&block)
    value = nil
    find do |item|
      value = yield item
      value.present?
    end
    value
  end

end
