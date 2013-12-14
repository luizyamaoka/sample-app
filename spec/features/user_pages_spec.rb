require 'spec_helper'
	
	describe "User pages" do

		subject { page }
		
		describe "signup_page" do
			before { visit signup_path }
			it { should have_selector('h1', text: 'Sign up') }
		end

	end
