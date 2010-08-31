class UsersController < ApplicationController

  hobo_user_controller


  auto_actions :all, :except => [ :index, :new, :create ]

  def base_url
    (ActionController::Base.relative_url_root || "") + '/admin/'
  end

  def do_signup
    do_creator_action :signup, :redirect => TaliaCore::CONFIG['login_redirect_url'] 
  end

  
end
