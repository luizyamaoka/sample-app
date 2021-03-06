require 'spec_helper'

describe "AuthenticationPages" do

	subject { page }

	describe "sign in page" do
		before { visit signin_path }

		it { should have_selector('h1', text: 'Sign in') }

		describe "with invalid information" do 
			before { click_button "Sign in" }

			it { should have_error_message('Invalid') }

			describe "after visiting another page" do
				before { click_link "Home" }
				it { should_not have_selector('div.alert.alert-error') }
			end
		end

		describe "with valid information" do
			let(:user) { FactoryGirl.create(:user) }
			before { valid_signin(user) }

			it{ should have_link('Users', href: users_path) }
			it{ should have_link('Profile', href: user_path(user)) }
			it{ should have_link('Settings', href: edit_user_path(user)) }
			it{ should have_link('Sign out', href: signout_path) }
			it{ should_not have_link('Sign in', href: signin_path) }

			describe "followed by signout" do
				before { click_link "Sign out" }
				it{ should_not have_link('Users', href: users_path) }
				it{ should_not have_link('Profile', href: user_path(user)) }
				it{ should_not have_link('Settings', href: edit_user_path(user)) }
				it{ should_not have_link('Sign out', href: signout_path) }
				it { should have_link('Sign in', href: signin_path) }
			end

		end

	end

	describe "authorization" do

		describe "for non-signed-in users" do
			let(:user) { FactoryGirl.create(:user) }

			describe "visiting the edit page" do
				before { visit edit_user_path(user) }
				it { should have_selector('h1', text: 'Sign in') }
			end

			describe "submitting to the update action" do
				before { put user_path(user) }
				specify { response.should redirect_to(signin_path) }
			end

			describe "when attempting to visit a protected page" do
				before do
					visit edit_user_path(user)
					fill_in "Email", with: user.email
					fill_in "Password", with: user.password
					click_button "Sign in"
				end

				describe "after signing in" do
					it "should render the desired protected page" do
						page.should have_selector('h1', text: "Update your profile")
					end

					describe "when signing in again" do
						before do
							visit signin_path
							fill_in "Email", with: user.email
							fill_in "Password", with: user.password
							click_button "Sign in"
						end

						it "should render the default (profile) page" do
							page.should have_selector('h1', text: user.name)
						end
					end
				end
			end

			describe "in the Users controller" do

				describe "visiting the user index" do
					before { visit users_path }
					it { should have_selector('h1', text: 'Sign in') }
				end
			end

			describe "in the Microposts controlller" do

				describe "submitting to the create action" do
					before { post microposts_path }
					specify { response.should redirect_to(signin_path) }
				end

				describe "submitting to the destroy action" do
					before do
						micropost = FactoryGirl.create(:micropost)
						delete micropost_path(micropost)
					end
					specify { response.should redirect_to(signin_path) }
				end
			end

		end

		describe "as wrong user" do
			let(:user) { FactoryGirl.create(:user) }
			let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
			before { valid_signin user }

			describe "visiting Users#edit page" do
				before { visit edit_user_path(wrong_user) }
				it { should_not have_selector('h1', text: 'Update your profile') }
			end

			describe "submitting a PUT request to the Users#update action" do
				before { put user_path(wrong_user) }
				specify { response.should redirect_to(root_path) }
			end
		end

		describe "as non-admin user" do
			let(:user) { FactoryGirl.create(:user) }
			let(:non_admin) { FactoryGirl.create(:user) }

			before { valid_signin non_admin }

			describe "submitting a DELETE request to the Users#destroy action" do
				before { delete user_path(user) }
				specify { response.should redirect_to(root_path) }
			end
		end

		describe "as admin user" do
			let(:admin) { FactoryGirl.create(:admin) }

			before { valid_signin admin }

			#describe "deleting himself" do
			#	before { delete user_path(admin) }
			#	specify {
			#		response.should redirect_to(root_path),
			#		flash[:error].should = 'Admin cannot destroy himself'
			#	}
			#end

			it "should not destroy himself" do
				expect { delete user_path(admin) }.to change(User, :count).by(0)
			end				
		end

	end

end
