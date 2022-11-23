class UsersController < ApplicationController
  def index
    users = User.all
    render json: users, only: [ :id, :name, :email, :login, :active, :last_login_at ]
  end

  def create
    user = User.new user_params

    if user.valid?
      role = Role.create(name: user.login, system_role: false,
        permissions: params[:role][:permissions])
      user.roles << role
      user.save
    else
      errors = {
        errors: user.errors,
        messages: user.errors.full_messages
      }
      render json: errors, status: :unprocessable_entity
    end
  end

  def show
    user = User.find params[:id]
    render json: user, only: [ :id, :name, :email, :login, :active,
      :last_login_at ], include: { roles: { only: [:name, :system_role] } }
  end

  private

  def user_params
    params.require(:user).permit(:name, :login, :email, :password,
      :password_confirmation)
  end
end
