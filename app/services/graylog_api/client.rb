require 'http'

module GraylogApi
  class Client
    attr_reader :uri, :user, :password
    private :uri, :user, :password

    def initialize
      @uri = ENV['GRAYLOG_API_URI']
      @user = ENV['GRAYLOG_API_USER']
      @password = ENV['GRAYLOG_API_PASSWORD']
    end

    def get(endpoint)
      rescue_errors { SuccessResponse.new(http.get(URI("#{uri}#{endpoint}").to_s)) }
    end

    def post(endpoint, payload)
      rescue_errors { SuccessResponse.new(http.post(URI("#{uri}#{endpoint}").to_s, json: payload)) }
    end

    def put(endpoint, payload)
      rescue_errors { SuccessResponse.new(http.put(URI("#{uri}#{endpoint}").to_s, json: payload)) }
    end

    def delete(endpoint, id)
      rescue_errors { SuccessResponse.new(http.delete(URI("#{uri}#{endpoint}/#{id}").to_s)) }
    end

    private

    def rescue_errors
      yield
    rescue HTTP::Error, StandardError => e
      FailureResponse.new(e)
    end

    def http
      HTTP.headers(accept: 'application/json', 'X-Requested-By': 'Graylog API bot').basic_auth(
        user: user, pass: password
      )
    end

    class SuccessResponse
      attr_reader :response
      private :response

      SUCCESS = 'Graylog stream successfully created'.freeze

      def initialize(response)
        @response = response
      end

      def body
        body = response.parse
        return {} if body.empty?

        body.transform_keys(&:to_sym)
      end

      def success?
        response.status.success?
      end

      def message
        SUCCESS
      end
    end
    private_constant :SuccessResponse

    class FailureResponse
      attr_reader :error
      private :error

      FAILURE = 'Could not create Graylog stream'.freeze

      def initialize(error)
        @error = error
      end

      def body
        { type: error.class.name, message: error.message, stack_trace: error.full_message }
      end

      def success?
        false
      end

      def message
        FAILURE
      end
    end
    private_constant :FailureResponse
  end
end
