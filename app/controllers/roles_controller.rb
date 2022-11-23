class RolesController < ApplicationController
  def index
    roles = Role.all
    render json: roles
  end

  def create
    role = Role.new role_params

    if role.valid?
      role.save
      head :ok
    else
      errors = {
        errors: role.errors,
        messages: role.errors.full_messages
      }
      render json: errors, status: :unprocessable_entity
    end
  end

  private

  def role_params
    params.require(:role).permit(:name, :description, permissions: [])
  end
end
