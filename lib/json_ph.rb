require "httparty"
require "pry"

module JSONph
  class Client
    include HTTParty
    debug_output $stdout if ENV["VERBOSE"] == "true"

    base_uri "http://jsonplaceholder.typicode.com"
    headers "Connection" => "keep-alive"
    headers "User-Agent" => "JSONph::Client"

    attr_reader :path

    def initialize(path: nil)
      @path = path ? path : []
      @call_methods = %i{get post patch put delete options head}
    end

    def method_missing(method_name, *args)
      if @call_methods.include?(method_name)
        call(method_name, *args)
      else
        append(method_name.to_s)
      end
    end

    def append(method_name)
      Client.new(path: @path.push(method_name))
    end

    def call(method_name, opts = {})
      path_string = @path.join("/")
      clear_path
      self.class.send(method_name, "/#{path_string}", opts)
    end

    def clear_path
      @path.clear
    end
  end
end
