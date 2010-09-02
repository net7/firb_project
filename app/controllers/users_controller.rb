class UsersController < ApplicationController

  hobo_user_controller

  auto_actions :all, :except => [ :index, :new, :create ]

  def base_url
    (ActionController::Base.relative_url_root || "") + '/admin/'
  end


  
  def json_signup
    error = 0
    data = ''
    html = ''
    @user = User.find_by_email_address(params[:user][:email_address])
    if @user
      # return the user already exists json
      html = 'Utente o Password esistenti'
      # no we can't have a common render at the bottom of file,
      # the things inside do_creator_action would try to render something else
      render :json => {'error' => error,
        'html' => html,
        'data' => data
      } and return
    else
      do_creator_action :signup do
        if valid?
          # success, return some json
          html =  'Utente creato con successo'
          # we must render it now or hobo/rails will render something on their own
          render :json => {'error' => error,
            'html' => html,
            'data' => data
          } and return
        else
          # we have some errors
          html = '<ul>'
          this.errors.full_messages.each do |error|
            html = "#{html} <li> #{error.to_s} </li>"
          end
          html = "#{html} </ul>"
          error = 1
          # we must render it now or hobo/rails will render something on their own
          render :json => {'error' => error,
            'html' => html,
            'data' => data
          } and return

        end
      end
    end
  end


  
end
