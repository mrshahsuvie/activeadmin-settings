class ActiveadminSettings::SettingsController < ApplicationController
  include Pundit

  unless ActiveAdmin.application.authentication_method.nil?
    before_action ActiveAdmin.application.authentication_method
  end

  def update
    @object = ActiveadminSettings::Setting.find(params[:id])

    if defined? ActiveadminSettings::SettingPolicy
      unless ActiveadminSettings::SettingPolicy.new(current_admin_user, @object).update?
        raise Pundit::NotAuthorizedError, "not allowed to update? this #{@object.inspect}"
      end
    end

    @object.assign_attributes(permitted_params[:setting])
    if @object.valid?
      @object.save!
      if @object.type == "file"
        render partial: "admin/settings/form", locals: {setting: @object}
      else
        render :plain => @object.value
      end
    else
      render :plain => @object.errors.full_messages.join(', '), status: 422
    end
  end

  private
  def permitted_params
    params.permit!
  end
end
