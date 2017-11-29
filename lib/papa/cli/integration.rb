module Papa
  module CLI
    class Integration < Thor
      desc 'start', 'Start an integration branch'
      option :base_branch, aliases: '-b', required: true
      def start
        base_branch = options[:base_branch]

        require 'papa/task/integration/start'
        Task::Integration::Start.new(base_branch: base_branch).run
      end
    end
  end
end
