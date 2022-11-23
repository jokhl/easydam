class BasketController < ApplicationController
  include Zipline

  before_action :create_basket

  def add
    begin
      session[:basket] << params[:asset_id]
      head 200
    rescue
      head 500
    end
  end

  def show
    if params[:full]
      assets = Asset.where(id: session[:basket])
      render json: assets
    else
      render json: session[:basket]
    end
  end

  def download
    assets = Asset.where(id: session[:basket]).map{ |asset| [asset.file, asset.filename] }
    ap assets
    zipline(assets, 'easydam-basket.zip')
  end

  def clear
    session[:basket] = []
    head 200
  end

  private

  def create_basket
    if session[:basket].nil?
      session[:basket] = []
    end
  end
end
