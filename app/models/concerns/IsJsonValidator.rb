class IsJsonValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value and not value.blank?
    JSON.parse(value)
  rescue JSON::ParserError, TypeError
    record.errors.add attribute, (options[:message] || "is not valid JSON")
  end
end
