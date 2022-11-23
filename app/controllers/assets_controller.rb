class AssetsController < ApplicationController
  def index
    page = params[:page] || 1
    assets = Asset
      .where(status: :active)
      .order(:created_at)
      .page(page)
      .per(current_user[:per_page] || 100)
    total = Asset.count
    count_per_page = assets.size
    total_pages = assets.total_pages
    current_page = assets.current_page
    offset = assets.offset_value
    
    render json: {
      pagination: {
        total: total,
        count_per_page: count_per_page,
        total_pages: total_pages,
        current_page: current_page,
        offset: offset
      },
      assets: assets.as_json(
        only: [
          :id,
          :description,
          :file_data,
          :created_at,
          :updated_at
        ]
      )
    }
  end

  def create
    asset = Asset.new asset_params

    if asset.valid?
      asset.save
      render json: asset.to_json
    else
      render json: asset.errors, status: :unprocessable_entity
    end
  end

  def show
    asset = Asset.find params[:id]
    render json: asset
  end

  private

  def asset_params
    params.require(:asset).permit(:name, :asset_type, :metadata, :color_tag, :status, :file)
  end
end
