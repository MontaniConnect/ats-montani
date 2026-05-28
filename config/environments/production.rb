require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.cache_store = :memory_store

  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
  config.assets.digest = true

  config.log_level = :info
  config.log_tags = [ :request_id ]

  config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  config.log_formatter = ::Logger::Formatter.new

  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :test

  config.i18n.fallbacks = [I18n.default_locale]
  config.action_view.full_sanitizer_class = Rails::Html::Sanitizer
  config.action_view.sanitized_allowed_tags = %w( b i p code pre tt samp kbd var sub sup dfn mark abbr acronym strong em a href span br hr div ul ol li dl dt dd )

  config.active_support.report_deprecations = false
  config.active_support.use_standard_json_encoder = true

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    STDOUT.sync = true
    config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  end
end
