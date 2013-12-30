class UsersController < ApplicationController
  before_filter :signed_in_user,  only: [:index, :edit, :update, :destroy]
  before_filter :correct_user,    only: [:edit, :update]
  before_filter :admin_user,      only: [:destroy]

  attr_accessor :name, :email

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
  	@user = User.find(params[:id])
  end

  def new
    if signed_in?
      redirect_to root_path
    else
  	 @user = User.new
    end
  end

  def create
  	@user = User.new(params[:user])
    if signed_in?
      redirect_to root_path
  	else 
      if @user.save
      flash[:success] = "Welcome to the Sample app!"
      sign_in @user
  		redirect_to @user
    	else
    		render 'new'
    	end
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    if current_user?(@user)
      flash[:error] = 'Admin cannot destroy himself'
      redirect_to root_path
    else
      @user.destroy
      flash[:success] = "User destroyed"
      redirect_to users_path
    end
  end

  private

    def signed_in_user
      unless signed_in?
        store_location
        redirect_to signin_path, notice: "Please sign in"
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end

end
