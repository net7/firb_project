class UsersController < ApplicationController

  hobo_user_controller

  auto_actions :all, :except => [ :index, :new, :create ]

  def base_url
    (ActionController::Base.relative_url_root || "") + '/admin/'
  end
  

  def json_forgot_password
    do_creator_action :forgot_password do
      if valid?
        render :text => 'andata'
      else
        render :text => this.error.messages.to_s
      end
    end
  end

  def json_signup
    html = ''
    @user = User.find_by_email_address(params[:user][:email_address])
    if @user
      # return the user already exists json
      html = 'Utente o indirizzo email già registrati'
      # no we can't have a common render at the bottom of file,
      # the things inside do_creator_action would try to render something else
      render :json => {'error' => 0,
        'html' => html,
        'data' => { :signup_error => 1 }
      } and return
    else
      do_creator_action :signup do
        if valid?
          # success, return some json
          html =  'Utente creato con successo'
          # we must render it now or hobo/rails will render something on their own
          render :json => {'error' => 0,
            'html' => html,
            'data' => { :signup_error => 0 }
          } and return
        else
          # we have some errors
          html = '<ul>'
          this.errors.full_messages.each do |error|
            html = "#{html} <li> #{error.to_s} </li>"
          end
          html = "#{html} </ul>"
          # we must render it now or hobo/rails will render something on their own
          render :json => {'error' => 0,
            'html' => html,
            'data' => { :signup_error => 1 }
          } and return

        end
      end
    end
  end


  
end
