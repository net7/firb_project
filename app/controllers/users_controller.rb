class UsersController < ApplicationController

  hobo_user_controller

  #  after_filter :redirect_to_frontsite, :only => [:login]

  auto_actions :all, :except => [ :index, :new, :create ]

  def base_url
    (ActionController::Base.relative_url_root || "") + '/admin/'
  end

#  def do_signup
#    hobo_do_signup  do
#      redirect_to TaliaCore::CONFIG['login_redirect_url'] unless current_user.instance_of? Guest
#    end
#  end




  def do_signup
    do_creator_action :signup, :redirect => TaliaCore::CONFIG['login_redirect_url'] 
  end
#  def login
#    hobo_login :redirect_to => TaliaCore::CONFIG['login_redirect_url']
#  end
  #  def redirect_to_frontsite
  #    redirect_to TaliaCore::CONFIG['login_redirect_url'] and return
  #  end

end
