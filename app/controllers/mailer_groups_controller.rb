class MailerGroupsController < ApplicationController
  respond_to :html
  before_action :require_admin!

  expose(:mailer_group, attributes: :mailer_group_params)
  expose(:mailer_groups) do
    MailerGroup.order_by(id: :desc)
  end

  def index; end
  def new; end
  def show; end

  def add_user
    email = params['mailer_group']['email']
    user = User.where(email: email).to_a.first
    if mailer_group && user
      mailer_group.user_ids << user.id.to_s
      mailer_group.user_ids.uniq!
      mailer_group.save
    end
    redirect_to mailer_groups_path
  end

  def remove_user
    email = params['mailer_group']['email']
    user = User.where(email: email).to_a.first
    if mailer_group && user
      mailer_group.user_ids.delete(user.id.to_s)
      mailer_group.user_ids.uniq!
      mailer_group.save
    end
    redirect_to mailer_groups_path
  end

  def create
    if mailer_group.save
      flash[:success] = "create mailer group success."
      redirect_to mailer_groups_path
    else
      render :new
    end
  end

protected

  def mailer_group_params
    @mailer_group_params ||= params[:mailer_group] ? params.require(:mailer_group).permit(*[:name]) : {}
  end
end
