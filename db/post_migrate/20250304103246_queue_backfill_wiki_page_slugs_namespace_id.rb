# frozen_string_literal: true

class QueueBackfillWikiPageSlugsNamespaceId < Gitlab::Database::Migration[2.2]
  milestone '17.10'
  restrict_gitlab_migration gitlab_schema: :gitlab_main_cell

  MIGRATION = "BackfillWikiPageSlugsNamespaceId"
  DELAY_INTERVAL = 2.minutes
  BATCH_SIZE = 1000
  SUB_BATCH_SIZE = 100

  def up
    queue_batched_background_migration(
      MIGRATION,
      :wiki_page_slugs,
      :id,
      :namespace_id,
      :wiki_page_meta,
      :namespace_id,
      :wiki_page_meta_id,
      job_interval: DELAY_INTERVAL,
      batch_size: BATCH_SIZE,
      sub_batch_size: SUB_BATCH_SIZE
    )
  end

  def down
    delete_batched_background_migration(
      MIGRATION,
      :wiki_page_slugs,
      :id,
      [
        :namespace_id,
        :wiki_page_meta,
        :namespace_id,
        :wiki_page_meta_id
      ]
    )
  end
end
