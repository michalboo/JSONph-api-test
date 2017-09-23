require_relative "../spec_helper"


describe JSONph do
  before(:all) do
    @client = JSONph::Client.new
    @valid_user_id = @client.users.get.parsed_response.sample["id"]
  end

  let(:required_user_fields) { %w(name username email phone website) }
  let(:invalid_id_examples) {[
    0, # User IDs indexed at 1
    9237324, # Number known to exceed the number of existing users
    "Fifty-Five" # String value
  ]}

  context "GET /users" do
    before(:all) { @users = @client.users.get }

    context "when called without specifying query parameters" do
      it "returns a 200 response code" do
        expect(@users.code).to eq 200
      end

      it "returns a list of existing users" do
        expect(@users.parsed_response).to be_instance_of Array
        expect(@users.parsed_response).not_to be_empty
      end

      it "returns required fields with each of the listed users" do
        @users.parsed_response.each do |user|
          expect(user).to include *required_user_fields
        end
      end

      it "returns the expected headers with the response" do
        expected_headers = {
          "Cache-Control" => "public",
          "Connection" => "keep-alive",
          "Content-Type" => "application/json"
        }

        expected_headers.each do |header, expected_value|
          expect(@users.headers[header]).not_to eq nil
          expect(@users.headers[header]).to include expected_value
        end
      end
    end

    context "when called with query parameters" do


      it "returns results matching the given query" do
        required_user_fields.each do |field|
          param_value = @users.parsed_response.sample[field]
          response = @client.users.get(query: { field => param_value})
          expect(response.code).to eq 200
          expect(response.length).to eq 1
        end

      end

      it "doesn't support partial matches" do
        sample_username = @users.parsed_response.sample["username"]
        invalid_examples = [
          sample_username[0...-1], # Cut off last character
          "#{sample_username}_xxx", # Added extra characters
          "*" # Attempt at using wildcard matching
        ]

        invalid_examples.each do |example|
          response = @client.users.get(query: { "username" => example })
          expect(response.code).to eq 200
          expect(response.parsed_response).to be_empty
        end
      end
    end
  end

  context "GET /users/{ID}" do
    context "when called with a valid (existing) id" do
      before(:all) do
        @response = @client.users.append(@valid_user_id).get
      end

      it "returns a 200 response code" do
        expect(@response.code).to eq 200
      end

      it "returns the required fields in the response body" do
        expect(@response.parsed_response).to include *required_user_fields
      end
    end

    context "when called with an invalid (non-existent) id" do
      it "returns a 404 response code" do
        invalid_id_examples.each do |id|
          expect(@client.users.append(id).get.code).to eq 404
        end
      end
    end
  end

  context "PATCH /users/{ID}" do
    context "when called with a valid (existing) id" do
      before(:all) do
        @example_edit = {
          "name" => Faker::Name.name,
          "email" => Faker::Internet.email
        }
        @response = @client.users.append(@valid_user_id).patch(
          body: @example_edit
        )
      end

      it "returns a 200 response code" do
        expect(@response.code).to eq 200
      end

      it "includes the modified information in the response body" do
        @example_edit.each do |k,v|
          expect(@response.parsed_response[k]).to eq v
        end
      end
    end

    context "when called with an invalid (non-existent) id" do
      it "returns a 404 response code" do
        invalid_id_examples.each do |id|
          expect(@client.users.append(id).patch.code).to eq 404
        end
      end
    end
  end

  context "POST /users" do
    context "when given a valid user object" do
      before(:all) do
        @random_user = {
          "name" => Faker::Name.name,
          "username" => Faker::Internet.user_name,
          "email" => Faker::Internet.email,
          "phone" => Faker::PhoneNumber.phone_number,
          "website" => Faker::Internet.url
        }
        @response = @client.users.post(body: @random_user)
      end

      it "returns a 201 response code" do
        expect(@response.code).to eq 201
      end

      it "returns user information in the response body" do
        @random_user.keys.each do |field|
          expect(@response.parsed_response.keys).to include field
          expect(@response.parsed_response[field]).to eq @random_user[field]
        end
      end

      it "returns the user id in the response body" do
        expect(@response.parsed_response.keys).to include "id"
      end
    end
  end

  context "DELETE /users" do
    context "when called with a valid (existing) id" do
      before(:all) do
        valid_id = @client.users.get.parsed_response.sample["id"]
        @response = @client.users.append(valid_id).delete
      end

      it "returns a 200 response code" do
        expect(@response.code).to eq 200
      end

      it "returns an empty body" do
        expect(@response.parsed_response).to be_empty
      end
    end

    context "when called with an invalid (non-existent) id" do
      it "returns a 404 response code" do
        invalid_id_examples.each do |id|
          expect(@client.users.append(id).delete.code).to eq 404
        end
      end
    end
  end
end
