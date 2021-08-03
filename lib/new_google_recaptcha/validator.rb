require 'net/http'

module NewGoogleRecaptcha
  class Validator
    attr_reader :score
    attr_reader :token, :action, :minimum_score, :secret_key

    def initialize(token:, action:, minimum_score:, secret_key: nil)
      @token         = token
      @action        = action
      @minimum_score = minimum_score
      @secret_key    = secret_key
    end

    def call
      uri    = NewGoogleRecaptcha.compose_uri(token, secret_key)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      result = JSON.parse(http.request(Net::HTTP::Get.new(uri)).body)

      @score = result['score'].to_f

      conditions = []
      conditions << !!result['success']
      conditions << (result['score'].to_f >= minimum_score)
      conditions << (result['action'].to_s == action.to_s)
      conditions.none?(&:!)
    end
  end
end
