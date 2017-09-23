require_relative "spec_helper"

describe JSONph::Client do
  before(:each) { @client = JSONph::Client.new }

  describe "::new" do
    it "Initializes a JSONph::Client class" do
      expect(JSONph::Client.new).to be_instance_of(JSONph::Client)
    end

    context "When given a :path keyword argument" do

      it "doesn't raise an error" do
        expect{
          JSONph::Client.new(path: ["arbitrary_path"])
        }.not_to raise_error
      end

      it "exposes the given value as the path attribute" do
        path_list = ["posts", "old"]
        path_client = JSONph::Client.new(path: path_list)
        expect(path_client.path).to eq path_list
      end
    end
  end

  describe "#method_missing" do
    it "appends missing method name to path" do
      expect{ @client.arbitrary_method_name }.not_to raise_error
      expect(@client.path.length).to eq 1
      expect(@client.path).to eq ["arbitrary_method_name"]
    end

    it "allows for chaining multiple missing methods to form multi-element paths" do
      expect{ @client.multiple.appended.elements }.not_to raise_error
      expect(@client.path.length).to eq 3
      expect(@client.path).to eq ["multiple", "appended", "elements"]
    end

    it "returns an HTTParty response when called with GET" do
      response = @client.made_up_path.get
      expect(response).to be_instance_of HTTParty::Response
      expect(response.request.http_method).to eq Net::HTTP::Get
    end

    it "returns an HTTParty response when called with POST" do
      response = @client.made_up_path.post
      expect(response).to be_instance_of HTTParty::Response
      expect(response.request.http_method).to eq Net::HTTP::Post
    end

    it "returns an HTTParty response when called with PUT" do
      response = @client.made_up_path.put
      expect(response).to be_instance_of HTTParty::Response
      expect(response.request.http_method).to eq Net::HTTP::Put
    end

    it "returns an HTTParty response when called with PATCH" do
      response = @client.made_up_path.patch
      expect(response).to be_instance_of HTTParty::Response
      expect(response.request.http_method).to eq Net::HTTP::Patch
    end

    it "returns an HTTParty response when called with DELETE" do
      response = @client.made_up_path.delete
      expect(response).to be_instance_of HTTParty::Response
      expect(response.request.http_method).to eq Net::HTTP::Delete
    end
  end

  describe "#append" do
    it "allows to append an arbitrary string to the path" do
      expect{
        @client.append("1").append("_").append(" ")
      }.not_to raise_error
      expect(@client.path).to eq ["1", "_", " "]
    end

    it "can be combined with standard method_missing usage" do
      @client.posts.append("1").comments
      expect(@client.path).to eq ["posts", "1", "comments"]
    end
  end

  describe "#call" do
    it "invokes an HTTParty request call" do
      response = @client.call(:get)
      expect(response).to be_instance_of HTTParty::Response
      expect(response.request.http_method).to eq Net::HTTP::Get
    end

    it "results in the path list being cleared" do
      @client.posts
      expect(@client.path.length).to eq 1
      @client.call(:get)
      expect(@client.path.length).to eq 0
    end
  end

  describe "#clear_path" do
    it "clears the path list" do
      @client.one.two.three
      expect(@client.path.length).to eq 3
      @client.clear_path
      expect(@client.path.length).to eq 0
    end
  end
end
