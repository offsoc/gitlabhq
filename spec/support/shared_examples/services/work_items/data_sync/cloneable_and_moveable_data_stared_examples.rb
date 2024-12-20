# frozen_string_literal: true

RSpec.shared_examples 'cloneable and moveable work item' do
  it 'increases the target namespace work items count by 1' do
    expect do
      service.execute
    end.to change { target_namespace.work_items.count }.by(1)
  end

  it 'runs all widget callbacks' do
    create_service_params = {
      work_item: anything, target_work_item: anything, current_user: current_user, params: anything
    }

    cleanup_service_params = {
      work_item: anything, target_work_item: nil, current_user: current_user, params: anything
    }

    original_work_item.widgets.flat_map(&:sync_data_callback_class).each do |callback_class|
      allow_next_instance_of(callback_class, **create_service_params) do |callback_instance|
        expect(callback_instance).to receive(:before_create)
        expect(callback_instance).to receive(:after_save_commit)
      end

      # move service also calls cleanup callbacks
      next unless described_class == WorkItems::DataSync::MoveService

      allow_next_instance_of(callback_class, **cleanup_service_params) do |callback_instance|
        expect(callback_instance).to receive(:post_move_cleanup)
      end
    end

    service.execute
  end

  it 'returns a new work item with the same attributes' do
    new_work_item = service.execute[:work_item]

    expect(new_work_item).to be_persisted
    expect(new_work_item).to have_attributes(original_work_item_attrs)
  end

  it 'handles original work item state' do
    service.execute

    expect(original_work_item.reload.state_id).to eq(expected_original_work_item_state)
  end
end

RSpec.shared_examples 'cloneable and moveable widget data' do
  using RSpec::Parameterized::TableSyntax

  def work_item_assignees(work_item)
    work_item.reload.assignees
  end

  def work_item_award_emoji(work_item)
    work_item.reload.award_emoji.pluck(:user_id, :name)
  end

  def work_item_emails(work_item)
    work_item.reload.email_participants.pluck(:email)
  end

  def work_item_milestone(work_item)
    work_item.reload.milestone&.title
  end

  let(:move) { WorkItems::DataSync::MoveService }
  let(:clone) { WorkItems::DataSync::CloneService }

  let_it_be(:users) { create_list(:user, 3) }
  let_it_be(:thumbs_ups) { create_list(:award_emoji, 2, name: 'thumbsup', awardable: original_work_item) }
  let_it_be(:thumbs_downs) { create_list(:award_emoji, 2, name: 'thumbsdown', awardable: original_work_item) }
  let_it_be(:participant2) { create(:issue_email_participant, issue: original_work_item, email: 'user2@example.com') }
  let_it_be(:award_emojis) { original_work_item.reload.award_emoji.pluck(:user_id, :name) }

  let_it_be(:emails) do
    create_list(:issue_email_participant, 2, issue: original_work_item)
    # create email participants on original work item and return emails as `expected_data` for later comparison.
    original_work_item.reload.email_participants.map(&:email)
  end

  let_it_be(:assignees) do
    original_work_item.assignee_ids = users.map(&:id)
    # set assignees and return assigned users as `expected_data` for later comparison.
    users
  end

  let_it_be(:milestone) do
    milestone = if original_work_item.namespace.is_a?(Group)
                  create(:milestone, group: original_work_item.namespace)
                else
                  create(:project_milestone, project: original_work_item.project)
                end

    original_work_item.update!(milestone: milestone)

    # create milestone with same title in destination namespace so that it can be assigned to moved work item
    if target_namespace.is_a?(Group)
      create(:milestone, group: target_namespace, title: milestone.title)
    elsif target_namespace.is_a?(Namespaces::ProjectNamespace)
      create(:project_milestone, project: target_namespace.project, title: milestone.title)
    else
      create(:project_milestone, project: target_namespace, title: milestone.title)
    end

    milestone.title
  end

  where(:widget_name, :eval_value, :expected_data, :operations) do
    :assignees          | :work_item_assignees   | ref(:assignees)    | [ref(:move), ref(:clone)]
    :award_emoji        | :work_item_award_emoji | ref(:award_emojis) | [ref(:move)]
    :email_participants | :work_item_emails      | ref(:emails)       | [ref(:move)]
    :milestone          | :work_item_milestone   | ref(:milestone)    | [ref(:move), ref(:clone)]
  end

  with_them do
    context "with widget" do
      it 'clones and moves widget data' do
        new_work_item = service.execute[:work_item]
        widget_value = send(eval_value, new_work_item)

        if operations.include?(described_class)
          expect(widget_value).not_to be_blank
          # trick to compare single values and arrays with a single statement
          expect([widget_value].flatten).to match_array([expected_data].flatten)
        else
          expect(widget_value).to be_blank
        end

        expect(original_work_item.reload.public_send(widget_name)).to be_blank if described_class == move
      end
    end
  end
end
