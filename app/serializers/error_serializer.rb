module ErrorSerializer

  def self.serialize(errors)
    return if errors.nil?

    json = {}
    new_hash = errors.to_hash(true).map do |k, v|
      v.map do |msg|
        { id: k, title: msg }
      end
    end.flatten
    json[:errors] = new_hash
    json
  end

  def self.serialize_password(errors)
    return if errors.nil?

    json = {}
    new_hash = errors.to_hash.map do |k, v|
      v.map do |msg|
        { id: k, title: msg }
      end
    end.flatten
    # json[:id] = new_hash
    json[:errors] = new_hash
    json
  end
end
