require 'spec_helper'

describe Milestone, 'Milestoneish' do
  let(:author) { create(:user) }
  let(:assignee) { create(:user) }
  let(:non_member) { create(:user) }
  let(:member) { create(:user) }
  let(:guest) { create(:user) }
  let(:admin) { create(:admin) }
  let(:project) { create(:empty_project, :public) }
  let(:milestone) { create(:milestone, project: project) }
  let!(:issue) { create(:issue, project: project, milestone: milestone) }
  let!(:security_issue_1) { create(:issue, :confidential, project: project, author: author, milestone: milestone) }
  let!(:security_issue_2) { create(:issue, :confidential, project: project, assignees: [assignee], milestone: milestone) }
  let!(:closed_issue_1) { create(:issue, :closed, project: project, milestone: milestone) }
  let!(:closed_issue_2) { create(:issue, :closed, project: project, milestone: milestone) }
  let!(:closed_security_issue_1) { create(:issue, :confidential, :closed, project: project, author: author, milestone: milestone) }
  let!(:closed_security_issue_2) { create(:issue, :confidential, :closed, project: project, assignees: [assignee], milestone: milestone) }
  let!(:closed_security_issue_3) { create(:issue, :confidential, :closed, project: project, author: author, milestone: milestone) }
  let!(:closed_security_issue_4) { create(:issue, :confidential, :closed, project: project, assignees: [assignee], milestone: milestone) }
  let!(:merge_request) { create(:merge_request, source_project: project, target_project: project, milestone: milestone) }

  before do
    project.team << [member, :developer]
    project.team << [guest, :guest]
  end

  describe '#closed_items_count' do
    it 'does not count confidential issues for non project members' do
      expect(milestone.closed_items_count(non_member)).to eq 2
    end

    it 'does not count confidential issues for project members with guest role' do
      expect(milestone.closed_items_count(guest)).to eq 2
    end

    it 'counts confidential issues for author' do
      expect(milestone.closed_items_count(author)).to eq 4
    end

    it 'counts confidential issues for assignee' do
      expect(milestone.closed_items_count(assignee)).to eq 4
    end

    it 'counts confidential issues for project members' do
      expect(milestone.closed_items_count(member)).to eq 6
    end

    it 'counts all issues for admin' do
      expect(milestone.closed_items_count(admin)).to eq 6
    end
  end

  describe '#total_items_count' do
    it 'does not count confidential issues for non project members' do
      expect(milestone.total_items_count(non_member)).to eq 4
    end

    it 'does not count confidential issues for project members with guest role' do
      expect(milestone.total_items_count(guest)).to eq 4
    end

    it 'counts confidential issues for author' do
      expect(milestone.total_items_count(author)).to eq 7
    end

    it 'counts confidential issues for assignee' do
      expect(milestone.total_items_count(assignee)).to eq 7
    end

    it 'counts confidential issues for project members' do
      expect(milestone.total_items_count(member)).to eq 10
    end

    it 'counts all issues for admin' do
      expect(milestone.total_items_count(admin)).to eq 10
    end
  end

  describe '#complete?' do
    it 'returns false when has items opened' do
      expect(milestone.complete?(non_member)).to eq false
    end

    it 'returns true when all items are closed' do
      issue.close
      merge_request.close

      expect(milestone.complete?(non_member)).to eq true
    end
  end

  describe '#percent_complete' do
    it 'does not count confidential issues for non project members' do
      expect(milestone.percent_complete(non_member)).to eq 50
    end

    it 'does not count confidential issues for project members with guest role' do
      expect(milestone.percent_complete(guest)).to eq 50
    end

    it 'counts confidential issues for author' do
      expect(milestone.percent_complete(author)).to eq 57
    end

    it 'counts confidential issues for assignee' do
      expect(milestone.percent_complete(assignee)).to eq 57
    end

    it 'counts confidential issues for project members' do
      expect(milestone.percent_complete(member)).to eq 60
    end

    it 'counts confidential issues for admin' do
      expect(milestone.percent_complete(admin)).to eq 60
    end
  end

  describe '#remaining_days' do
    it 'shows 0 if no due date' do
      milestone = build_stubbed(:milestone)

      expect(milestone.remaining_days).to eq(0)
    end

    it 'shows 0 if expired' do
      milestone = build_stubbed(:milestone, due_date: 2.days.ago)

      expect(milestone.remaining_days).to eq(0)
    end

    it 'shows correct remaining days' do
      milestone = build_stubbed(:milestone, due_date: 2.days.from_now)

      expect(milestone.remaining_days).to eq(2)
    end
  end

  describe '#elapsed_days' do
    it 'shows 0 if no start_date set' do
      milestone = build_stubbed(:milestone)

      expect(milestone.elapsed_days).to eq(0)
    end

    it 'shows 0 if start_date is a future' do
      milestone = build_stubbed(:milestone, start_date: Time.now + 2.days)

      expect(milestone.elapsed_days).to eq(0)
    end

    it 'shows correct amount of days' do
      milestone = build_stubbed(:milestone, start_date: Time.now - 2.days)

      expect(milestone.elapsed_days).to eq(2)
    end
  end
end
