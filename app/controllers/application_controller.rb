class ApplicationController < ActionController::Base
  include Pundit
  
  helper_method :current_user_session, :current_user, :is_logged_in?

  rescue_from Pundit::NotAuthorizedError do |exception|
    respond_to do |format|
      format.json { head :forbidden, content_type: 'text/html' }
      format.html { redirect_to login_path, notice: exception.message }
      format.js   { head :forbidden, content_type: 'text/html' }
    end
  end

  private

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  def is_logged_in?
    return current_user ? true : false
  end

  def require_login
    unless is_logged_in?
      redirect_to new_login_path
    end
  end

  protected

  def handle_unverified_request
    # destroy session, redirect
    if current_user_session
      current_user_session.destroy
    end
    
    redirect_to new_login_path
  end
end
