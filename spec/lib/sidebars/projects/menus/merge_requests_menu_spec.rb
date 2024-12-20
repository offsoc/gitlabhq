# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidebars::Projects::Menus::MergeRequestsMenu, feature_category: :navigation do
  let_it_be(:project) { create(:project, :repository) }

  let(:user) { project.first_owner }
  let(:context) { Sidebars::Projects::Context.new(current_user: user, container: project) }

  subject { described_class.new(context) }

  it_behaves_like 'serializable as super_sidebar_menu_args' do
    let(:menu) { subject }
    let(:extra_attrs) do
      {
        item_id: :project_merge_request_list,
        pill_count: menu.pill_count,
        pill_count_field: menu.pill_count_field,
        has_pill: menu.has_pill?,
        super_sidebar_parent: Sidebars::Projects::SuperSidebarMenus::CodeMenu
      }
    end
  end

  describe '#render?' do
    context 'when repository is not present' do
      let(:project) { build(:project) }

      it 'returns false' do
        expect(subject.render?).to eq false
      end
    end

    context 'when repository is present' do
      context 'when user can read merge requests' do
        it 'returns true' do
          expect(subject.render?).to eq true
        end
      end

      context 'when user cannot read merge requests' do
        let(:user) { nil }

        it 'returns false' do
          expect(subject.render?).to eq false
        end
      end
    end
  end

  describe '#pill_count' do
    before do
      stub_feature_flags(async_sidebar_counts: false)
    end

    it 'returns zero when there are no open merge requests' do
      expect(subject.pill_count).to eq '0'
    end

    it 'memoizes the query' do
      subject.pill_count

      control = ActiveRecord::QueryRecorder.new do
        subject.pill_count
      end

      expect(control.count).to eq 0
    end

    context 'when there are open merge requests' do
      it 'returns the number of open merge requests' do
        create_list(:merge_request, 2, :unique_branches, source_project: project, author: user, state: :opened)
        create(:merge_request, source_project: project, state: :merged)

        expect(subject.pill_count).to eq '2'
      end
    end

    describe 'formatting' do
      context 'when the count value is over 1000' do
        before do
          allow(project).to receive(:open_merge_requests_count).and_return(1001)
        end

        it 'returns truncated digits' do
          expect(subject.pill_count).to eq('1k')
        end
      end
    end

    context 'when async_sidebar_counts feature flag is enabled' do
      before do
        stub_feature_flags(async_sidebar_counts: true)
      end

      it 'returns nil' do
        expect(subject.pill_count).to be_nil
      end
    end
  end

  describe '#pill_count_field' do
    it 'returns the correct GraphQL field name' do
      expect(subject.pill_count_field).to eq('openMergeRequestsCount')
    end

    context 'when async_sidebar_counts feature flag is disabled' do
      before do
        stub_feature_flags(async_sidebar_counts: false)
      end

      it 'returns nil' do
        expect(subject.pill_count_field).to be_nil
      end
    end
  end
end
