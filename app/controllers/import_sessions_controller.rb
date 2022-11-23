class ImportSessionsController < ApplicationController
  def index
    @import_sessions = ImportSession.where(status: :success).or(
      ImportSession.where(status: :partial)
    ).or(
      ImportSession.where(status: :error)
    ).order(created_at: :desc)
    render json: @import_sessions
  end

  def show
    @import_session = ImportSession.find(params[:id])
    render json: @import_session.to_json({
      include: :assets
    })
  end

  def create
    import_session = ImportSession.new import_session_params
    # We must manually validate before saving in order to remove the assets
    # that are not allowed. Otherwise, saving will fail.
    import_session.validate
    import_session.save

    if import_session.error?
      render json: import_session, status: 422
    else
      AnalyzeJob.perform_later(ImportSession.class.name, import_session.id)
      render json: import_session, status: 200
    end
  end

  private

  def import_session_params
    params.require(:import_session).permit(assets_attributes: [:file])
  end
end
