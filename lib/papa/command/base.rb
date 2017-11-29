require 'open3'
require 'papa/helper/output'

module Papa
  module Command
    class Base
      attr_accessor :command, :stdout, :stderr, :exit_status, :silent

      def initialize(command, options = {})
        @command = command
        @silent = options.has_key?(:silent) ? options[:silent] : false
      end

      def run
        return if command.nil?
        Helper::Output.stdout "Running #{command.bold}..." unless silent
        @stdout, @stderr, status = Open3.capture3(command)
        @exit_status = status.exitstatus
        self
      end

      def failure_message
        message = "Error while running #{command.bold}"
        Helper::Output.error message
        Helper::Output.error stderr
        message
      end

      def cleanup
        # Override me
      end

      def success?
        !failed?
      end

      def failed?
        exit_status != 0
      end

      private

      def current_branch
        @current_branch ||= `git symbolic-ref --short HEAD`.chomp
      end
    end
  end
end
