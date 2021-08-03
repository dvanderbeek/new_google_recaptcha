require "new_google_recaptcha/railtie"

module NewGoogleRecaptcha
  mattr_accessor :site_key
  mattr_accessor :secret_key
  mattr_accessor :minimum_score

  def self.setup
    yield(self)
  end

  def self.human?(token, action, minimum_score = self.minimum_score, model = nil, secret_key = nil)
    is_valid =
      NewGoogleRecaptcha::Validator.new(
        token: token,
        action: action,
        minimum_score: minimum_score,
        secret_key: secret_key
      ).call

    if model && !is_valid
      model.errors.add(:base, self.i18n("new_google_recaptcha.errors.verification_human", "Looks like you are not a human"))
    end

    is_valid
  end

  def self.get_humanity_detailed(token, action, minimum_score = self.minimum_score, model = nil, secret_key = nil)
    validator =
      NewGoogleRecaptcha::Validator.new(
        token: token,
        action: action,
        minimum_score: minimum_score,
        secret_key: secret_key
      )

    is_valid = validator.call

    if model && !is_valid
      model.errors.add(:base, self.i18n("new_google_recaptcha.errors.verification_human", "Looks like you are not a human"))
    end

    { is_human: is_valid, score: validator.score, model: model }
  end

  def self.i18n(key, default)
    if defined?(I18n)
      I18n.translate(key, default: default)
    else
      default
    end
  end

  def self.compose_uri(token, secret_key = nil)
    secret_key ||= self.secret_key
    URI(
      "https://www.google.com/recaptcha/api/siteverify?"\
      "secret=#{secret_key}&response=#{token}"
    )
  end
end

require_relative "new_google_recaptcha/view_ext"
require_relative "new_google_recaptcha/validator"
