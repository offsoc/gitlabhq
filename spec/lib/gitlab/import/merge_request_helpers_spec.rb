# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Import::MergeRequestHelpers, type: :helper, feature_category: :importers do
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:user) { create(:user) }
  let_it_be(:merge_request) { create(:merge_request, source_project: project, iid: 999) }

  describe '.create_merge_request_without_hooks' do
    let(:iid) { 42 }

    let(:attributes) do
      {
        iid: iid,
        title: 'My Pull Request',
        description: 'This is my pull request',
        source_project_id: project.id,
        target_project_id: project.id,
        source_branch: 'master-42',
        target_branch: 'master',
        state_id: 3,
        author_id: user.id
      }
    end

    subject { helper.create_merge_request_without_hooks(project, attributes, iid) }

    context 'when merge request does not exist' do
      it 'returns a new object' do
        expect(subject.first).not_to be_nil
        expect(subject.second).to eq(false)
      end

      it 'does load all existing objects' do
        5.times do |iid|
          MergeRequest.create!(
            attributes.merge(iid: iid, source_branch: iid.to_s))
        end

        # ensures that we only load object once by project.merge_requests.find
        expect(MergeRequest).to receive(:allocate).once.and_call_original

        expect(subject.first).not_to be_nil
        expect(subject.second).to eq(false)
      end
    end

    context 'when merge request does exist' do
      before do
        MergeRequest.create!(attributes)
      end

      it 'returns an existing object' do
        expect(subject.first).not_to be_nil
        expect(subject.second).to eq(true)
      end
    end

    context 'when project is deleted' do
      before do
        project.delete
      end

      it 'returns an existing object' do
        expect(subject.first).to be_nil
      end
    end
  end

  describe '.insert_merge_request_reviewers' do
    subject { helper.insert_merge_request_reviewers(merge_request, reviewers) }

    context 'when reviewers are not present' do
      let(:reviewers) { nil }

      it 'does not insert reviewers' do
        expect { subject }.not_to change { MergeRequestReviewer.count }
      end
    end

    context 'when reviewers are present' do
      let(:reviewers) { create_list(:user, 3).pluck(:id) }

      it 'inserts reviewers' do
        expect { subject }.to change { MergeRequestReviewer.count }.by(3)
      end
    end
  end

  describe '.create_approval!', :aggregate_failures do
    let(:submitted_at) { Time.utc(2023, 1, 1, 1) }

    subject(:create_approval) { helper.create_approval!(project.id, merge_request.id, user.id, submitted_at) }

    it 'creates an approval and system note and returns them' do
      approval, note = create_approval

      expect(approval).to be_a(Approval)
      expect(approval).to have_attributes(
        merge_request_id: merge_request.id,
        user_id: user.id,
        created_at: submitted_at,
        updated_at: submitted_at
      )

      expect(note).to be_a(Note)
      expect(note).to have_attributes(
        importing: true,
        noteable_id: merge_request.id,
        noteable_type: 'MergeRequest',
        project_id: project.id,
        author_id: user.id,
        note: 'approved this merge request',
        system: true,
        created_at: submitted_at,
        updated_at: submitted_at
      )
      expect(note.system_note_metadata).to have_attributes(action: 'approved')
    end
  end
end
