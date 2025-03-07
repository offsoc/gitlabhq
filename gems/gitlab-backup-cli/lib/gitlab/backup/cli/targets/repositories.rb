# frozen_string_literal: true

require 'yaml'

module Gitlab
  module Backup
    module Cli
      module Targets
        # Backup and restores repositories by querying the database
        class Repositories < Target
          def dump(destination)
            gitaly_backup.start(:create, destination)
            enqueue_consecutive

          ensure
            gitaly_backup.finish!
          end

          def restore(source)
            gitaly_backup.start(:restore, source, remove_all_repositories: remove_all_repositories)
            enqueue_consecutive

          ensure
            gitaly_backup.finish!

            restore_object_pools
          end

          def gitaly_backup
            @gitaly_backup ||= Services::GitalyBackup.new(context)
          end

          private

          def remove_all_repositories
            context.config_repositories_storages.keys
          end

          def enqueue_consecutive
            enqueue_consecutive_projects
            enqueue_consecutive_snippets
          end

          def enqueue_consecutive_projects
            project_relation.find_each(batch_size: 1000) do |project|
              enqueue_project(project)
            end
          end

          def enqueue_consecutive_snippets
            snippet_relation.find_each(batch_size: 1000) { |snippet| enqueue_snippet(snippet) }
          end

          def enqueue_project(project)
            gitaly_backup.enqueue(project, Gitlab::Backup::Cli::RepoType::PROJECT)
            gitaly_backup.enqueue(project, Gitlab::Backup::Cli::RepoType::WIKI)

            return unless project.design_management_repository

            gitaly_backup.enqueue(project.design_management_repository, Gitlab::Backup::Cli::RepoType::DESIGN)
          end

          def enqueue_snippet(snippet)
            gitaly_backup.enqueue(snippet, Gitlab::Backup::Cli::RepoType::SNIPPET)
          end

          def project_relation
            Project.includes(:route, :group, :namespace)
          end

          def snippet_relation
            Snippet.all
          end

          def restore_object_pools
            PoolRepository.includes(:source_project).find_each do |pool|
              Output.info " - Object pool #{pool.disk_path}..."

              unless pool.source_project
                Output.info " - Object pool #{pool.disk_path}... [SKIPPED]"
                next
              end

              pool.state = 'none'
              pool.save

              pool.schedule
            end
          end
        end
      end
    end
  end
end
