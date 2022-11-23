class TagsController < ApplicationController
  def create
    asset = Asset.find params[:asset_id]
    tag_context = TagContext.find params[:asset][:tag_context_id]
    tag = params[:asset][:tag_value]

    if asset.nil?
      res = { error: "Asset does not exist." }
      render json: res, status: :unprocessable_entity
    elsif tag_context.nil?
      res = { error: "Tag does not exist." }
      render json: res, status: :unprocessable_entity
    elsif tag.nil? || tag.blank?
      res = { error: "Tag cannot be empty." }
      render json: res, status: :unprocessable_entity
    end

    tag_sym = tag_context.key.to_sym
    tags = asset.tag_list_on(tag_sym)
    tags << tag
    asset.save

    # Must have the same structure as the response from the 'index' action.
    render json: {
      context: tag_context.key,
      values: tags
    }
  end

  # References:
  # https://www.postgresql.org/docs/9.5/functions-aggregate.html
  def index
    asset = Asset.find params[:asset_id]
    
    if asset.nil?
      res = { error: "Asset does not exist." }
      render json: res, status: :unprocessable_entity
    end

    tags = asset
      .taggings
      .joins(:tag)
      .select("taggings.context, array_agg(tags.name) AS values")
      .group("taggings.context")

    render json: tags, only: [:context, :values]
  end
end
