require 'contrib/rails/apps/application'

require 'ddtrace'

module Rails5
  class Application < RailsTrace::TestApplication
  end
end

Rails5::Application.test_config()
