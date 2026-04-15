class HomeController < ApplicationController
  def index
    return unless user_signed_in?

    redirect_to(dashboard_path_for(current_user))
  end

  private

  def dashboard_path_for(user)
    return tickets_path if user&.colaborator?
    return buildings_path if user&.resident? || user&.admin?

    unauthenticated_root_path
  end
end
