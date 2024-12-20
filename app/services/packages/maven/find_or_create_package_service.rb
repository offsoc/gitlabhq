# frozen_string_literal: true

module Packages
  module Maven
    class FindOrCreatePackageService < BaseService
      include ::Gitlab::ExclusiveLeaseHelpers

      SNAPSHOT_TERM = '-SNAPSHOT'
      MAX_FILE_NAME_LENGTH = 5000

      def execute
        return ServiceResponse.error(message: 'File name is too long') if file_name_too_long?

        return find_or_create_package if ::Feature.disabled?(:use_exclusive_lease_in_mvn_find_or_create_package,
          project)

        # A temp exclusive lease to prevent race conditions. We will switch to use database `upsert`
        # when we have a unique index: https://gitlab.com/gitlab-org/gitlab/-/issues/424238#note_2187274213
        in_lock(lease_key, retries: 0) { find_or_create_package }
      rescue FailedToObtainLockError => e
        ServiceResponse.error(message: e.message, reason: :failed_to_obtain_lease)
      end

      private

      def find_or_create_package
        package =
          ::Packages::Maven::PackageFinder.new(current_user, project, path: path)
          .execute&.last

        return ServiceResponse.error(message: 'Duplicate package is not allowed') if duplicate_error?(package)

        unless package
          # Maven uploads several files during `mvn deploy` in next order:
          #   - my-company/my-app/1.0-SNAPSHOT/my-app.jar
          #   - my-company/my-app/1.0-SNAPSHOT/my-app.pom
          #   - my-company/my-app/1.0-SNAPSHOT/maven-metadata.xml
          #   - my-company/my-app/maven-metadata.xml
          #
          # The last xml file does not have VERSION in URL because it contains
          # information about all versions. When uploading such file, we create
          # a package with a version set to `nil`. The xml file with a version
          # is only created and uploaded for snapshot versions.
          #
          # Gradle has a different upload order:
          #   - my-company/my-app/1.0-SNAPSHOT/maven-metadata.xml
          #   - my-company/my-app/1.0-SNAPSHOT/my-app.jar
          #   - my-company/my-app/1.0-SNAPSHOT/my-app.pom
          #   - my-company/my-app/maven-metadata.xml
          #
          # The first upload has to create the proper package (the one with the version set).
          if file_name == Packages::Maven::Metadata.filename && !snapshot_version?
            package_name = path
            version = nil
          else
            package_name, _, version = path.rpartition('/')
          end

          package_params = {
            name: package_name,
            path: path,
            status: params[:status],
            version: version
          }

          service_response =
            ::Packages::Maven::CreatePackageService.new(project, current_user, package_params)
                                                   .execute

          return service_response if service_response.error?

          package = service_response[:package]
        end

        package.create_build_infos!(params[:build])

        ServiceResponse.success(payload: { package: package })
      end

      def duplicate_error?(package)
        return false if Namespace::PackageSetting.duplicates_allowed_for_package?(package)
        return false if Namespace::PackageSetting.matches_duplicate_exception?(package)

        target_package_is_duplicate?(package)
      end

      def file_name_too_long?
        return false unless file_name

        file_name.size > MAX_FILE_NAME_LENGTH
      end

      def target_package_is_duplicate?(package)
        # duplicate metadata files can be uploaded multiple times
        return false if package.version.nil?

        existing_file_names = strip_snapshot_parts(
          package.package_files
                 .map(&:file_name)
                 .compact
        )

        published_file_name = strip_snapshot_parts_from(file_name)
        existing_file_names.include?(published_file_name)
      end

      def strip_snapshot_parts(file_names)
        return file_names unless snapshot_version?

        Array.wrap(file_names).map { |f| strip_snapshot_parts_from(f) }
      end

      def strip_snapshot_parts_from(file_name)
        return file_name unless snapshot_version?
        return unless file_name

        match_data = file_name.match(Gitlab::Regex::Packages::MAVEN_SNAPSHOT_DYNAMIC_PARTS)

        if match_data
          file_name.gsub(match_data.captures.last, '')
        else
          file_name
        end
      end

      def snapshot_version?
        path&.ends_with?(SNAPSHOT_TERM)
      end

      def path
        params[:path]
      end

      def file_name
        params[:file_name]
      end

      def lease_key
        "#{self.class.name.underscore}:#{project.id}_#{path}"
      end
    end
  end
end
