module ApiNotify
  class SynchronizerWorker
    include Sidekiq::Worker
    sidekiq_options retry: 5, failures: :exhausted

    class FailedSynchronization < StandardError; end

    sidekiq_retries_exhausted do |msg|
      Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
    end

    def perform(id)
      task = Task.find(id)
      task.synchronize
      raise FailedSynchronization, task.response unless task.done
    end
  end
end
