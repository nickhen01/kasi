module Authorize
  extend ActiveSupport::Concern
  include Pundit::Authorization

  included do
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    private

    def user_not_authorized
      respond_to do |format|
        format.html do
          flash[:alert] = 'You are not authorized to perform this action !'
          redirect_to root_path
        end

        format.json do
          render json: { errors: 'Unauthorized access' }, status: 403
        end
      end
    end
  end
end