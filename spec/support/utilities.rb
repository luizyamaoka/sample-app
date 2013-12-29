include ApplicationHelper
	
	def valid_signup()
		fill_in "Name", 		with: "Example User"
		fill_in "Email", 		with: "user@example.com"
		fill_in "Password", 	with: "foobar"
		fill_in "Confirmation", with: "foobar"
	end

	def valid_signin(user)
		visit signin_path
		fill_in "Email", with: user.email
		fill_in "Password", with: user.password
		click_button "Sign in"
		cookies[:remember_token] = user.remember_token # Sign in when not using Capybara as well
	end

	Rspec::Matchers.define :have_error_message do |message|
		match do |page|
			page.should have_selector('div.alert.alert-error', text: message)
		end
	end

	Rspec::Matchers.define :have_success_message do |message|
		match do |page|
			page.should have_selector('div.alert.alert-success', text: message)
		end
	end

