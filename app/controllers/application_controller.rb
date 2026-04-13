class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from CanCan::AccessDenied do |_exception|
    if user_signed_in?
      redirect_to authenticated_root_path, alert: "Você não tem permissão para acessar esta página."
    else
      redirect_to new_user_session_path, alert: "Faça login para continuar."
    end
  end

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end
end
