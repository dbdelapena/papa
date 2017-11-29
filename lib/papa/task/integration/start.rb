require 'papa/task/common/start'
require 'date'

module Papa
  module Task
    module Integration
      class Start < Common::Start
        def initialize(base_branch:)
          @build_type = 'integration'
          @base_branch = base_branch
          @build_branch = generate_integration_branch_name
        end

        private

        def generate_integration_branch_name
          "integration/#{DateTime.now.strftime('%y.%m.%d.%H.%M').gsub('.0', '.')}"
        end
      end
    end
  end
end
