class PropertiesController < ApplicationController
  def index
    @properties = Property.all
    render json: @properties, only: [:id, :key, :name, :prop_type]
  end

  def create
    property = Property.new property_params
    
    if property.valid?
      property.save
      render json: property, only: [:id, :key, :name]
    else
      render json: {
        error_fields: property.errors.keys,
        error_messages: property.errors.full_messages
      }, status: 400
    end
  end

  def show
    property = Property.find params[:id]
    render json: property
  end

  private

  def property_params
    params.require(:property).permit(:name, :prop_type)
  end
end
