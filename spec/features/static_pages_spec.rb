require 'spec_helper'

describe "Static pages" do

	subject { page }

	describe "Home page" do
		before { visit root_path }
		it {should have_selector('h1', text: 'Sample App')}
		it {should have_content('Sample App')}

		describe "for signed-in users" do
			let(:user) { FactoryGirl.create(:user) }
			before do
				FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
				valid_signin user
				visit root_path
			end

			# count microposts correctly and use the single word micropost
			it { should have_content("1 micropost") }

			describe "with two microposts" do

				before do
					FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
					visit root_path
				end

				# count microposts correctly and use the plural word microposts
				it { should have_content("2 microposts") }

				it "should render the user's feed" do
					user.feed.each do |item|
						page.should have_selector("li##{item.id}", text:item.content)
					end
				end
			end

			# test pagination
			describe "pagination" do

				before do
					50.times { FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum") } 
					visit root_path
				end

				it { should have_selector('div.pagination') }

				it "should list each user" do
					user.microposts.paginate(page: 1).each do |micropost|
						page.should have_selector('li', text: micropost.content)
					end
				end
			end

		end
	end

	describe "Help page" do
		before { visit help_path }
		it {should have_selector('h1', text: 'Help')}
		it {should have_content('Help')}
	end

	describe "About page" do
		before { visit about_path }
		it {should have_selector('h1', text: 'About Us')}
		it {should have_content('About Us')}
	end

	describe "Contact page" do
		before { visit contact_path }
		it {should have_selector('h1', text: 'Contact')}
		it {should have_content('Contact')}
	end

end