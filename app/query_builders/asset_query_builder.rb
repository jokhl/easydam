class AssetQueryBuilder
  attr_reader :base_query, :query, :tags_joined

  def initialize(raw_query)
    @base_query = Asset.select(assets[Arel.star])
    @tags_joined = false
    @query = build_query(raw_query)
  end

  def execute(page_number: 1)
    @base_query.where(@query).page(page_number)
  end

  private

  def assets
    Asset.arel_table
  end

  def taggings
    ActsAsTaggableOn::Tagging.arel_table
  end

  def tags
    ActsAsTaggableOn::Tag.arel_table
  end

  def build_query(raw_query)
    if raw_query.empty?
      return {}
    end

    case raw_query[:type]
    when "sub_query"
      leftNode = build_query(raw_query[:operands][0])
      rightNode = build_query(raw_query[:operands][1])

      case raw_query[:operator]
      when "||"
        return leftNode.or(rightNode)
      when "&&"
        return leftNode.and(rightNode)
      else
        raise StandardError.new "Unknown operator: #{raw_query[:operator]}"
      end

    when "nested"
      components = raw_query[:operands][0].split(":")
      key = components[0]

      if components.size != 2
        raise StandardError.new "Malformed key: #{raw_query[:operands][0]}"
      end

      case key
      when "taggings_context"
        @base_query = @base_query.joins(taggings: :tag) unless @tags_joined
        tagValues = raw_query[:operands][1].split(";")

        case raw_query[:operator]
        when "=="
          return taggings[:context].eq(components[1])
            .and(tags[:name].eq_all(tagValues))
        when "!="
          return taggings[:context].eq(components[1])
            .and(tags[:name].not_in(tagValues))
        when "*="
          return taggings[:context].eq(components[1])
            .and(tags[:name].in(tagValues))
        when "^="
          return taggings[:context].eq(components[1])
            .and(tags[:name].not_eq_any(tagValues))
        else
          raise StandardError.new "Invalid operator: #{raw_query[:operator]}"
        end
      else
        raise StandardError.new "Unknown key: #{key}"
      end

    else
      field = raw_query[:operands][0].to_sym
      value = raw_query[:operands][1]

      case raw_query[:operator]
      when "=="
        return assets[field].eq(value)
      when "!="
        return assets[field].not_eq(value)
      when ">="
        return assets[field].gteq(value)
      when "<="
        return assets[field].lteq(value)
      when ">"
        return assets[field].gt(value)
      when "<"
        return assets[field].lt(value)
      when "*="
        return assets[field].in(value)
      when "~="
        return assets[field].matches("%#{value}%")
      else
        raise StandardError.new "Unknown operator: #{raw_query[:operator]}"
      end
    end
  end
end
