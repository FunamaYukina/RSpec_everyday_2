require 'rails_helper'

# RSpec.describe "ProjectsApis", type: :request do
#   describe "GET /projects_api" do
#     it "works! (now write some real specs)" do
#       get projects_api_path
#       expect(response).to have_http_status(200)
#     end
#   end
# end
describe 'Projects API' do
  #一件のプロジェクトを読み出すこと
  it 'loads a project' do
    user = FactoryBot.create(:user)
    FactoryBot.create(:project,
                      name: "Sample Project")
    FactoryBot.create(:project,
                      name: "Second Sample Project",
                      owner: user)

    get api_projects_path, params: {
        user_email: user.email,
        user_token: user.authentication_token
    }

    expect(response).to have_http_status(:success)
    json = JSON.parse(response.body)
    binding.pry
    expect(json.length).to eq 1
    project_id = json[0]["id"]

    get api_projects_path(project_id), params: {
        user_email: user.email,
        user_token: user.authentication_token
    }

    expect(response).to have_http_status(:success)
    json = JSON.parse(response.body)
    # binding.pry
    expect(json[0]["name"]).to eq "Second Sample Project"
  end

  #認証済みのユーザーとして
  context "as an authenticated user" do
    before do
      @user = FactoryBot.create(:user)
    end
   #有効な属性値の場合
    context "with valid attributes" do

      it "adds a project" do
        project_params = FactoryBot.attributes_for(:project)
        sign_in @user
        expect {
          post projects_path, params: {project: project_params}
          }.to change(@user.projects, :count).by(1)
      end
    end
    #無効な属性値の場合
    context do
      #プロジェクトを追加できないこと
      it "does not add a project" do
        project_params = FactoryBot.attributes_for(:project, :invalid)
        sign_in @user
        expect {
          post projects_path, params: {project: project_params}
        }.to_not change(@user.projects, :count)
      end
    end
  end

  #プロジェクトを作成できること
  it 'creates a project'do
    user=FactoryBot.create(:user)

    project_attributes=FactoryBot.attributes_for(:project)

    expect{
      post api_projects_path,params: {
          user_email: user.email,
          user_token: user.authentication_token,
          project: project_attributes
      }
    }.to change(user.projects, :count).by(1)

    expect(response).to have_http_status(:success)

  end

end