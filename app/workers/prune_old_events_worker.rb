# frozen_string_literal: true

class PruneOldEventsWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker

  data_consistency :sticky

  # rubocop:disable Scalability/CronWorkerContext
  # This worker does not perform work scoped to a context
  include CronjobQueue
  # rubocop:enable Scalability/CronWorkerContext

  feature_category :user_profile

  DELETE_LIMIT = 10_000

  def perform
    if Feature.enabled?(:ops_prune_old_events, type: :ops)
      # Contribution calendar shows maximum 12 months of events, we retain 3 years for data integrity.
      cutoff_date = (3.years + 1.day).ago

      Event.unscoped.created_before(cutoff_date).delete_with_limit(DELETE_LIMIT)
    else
      Gitlab::AppLogger.info(":ops_prune_old_events is disabled, skipping.")
    end
  end
end
