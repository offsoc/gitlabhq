import Vue from 'vue';
import VueApollo from 'vue-apollo';
import waitForPromises from 'helpers/wait_for_promises';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import BranchRule from '~/projects/settings/repository/branch_rules/components/branch_rule.vue';
import ProtectedBadge from '~/vue_shared/components/badges/protected_badge.vue';
import squashOptionQuery from '~/projects/settings/branch_rules/queries/squash_option.query.graphql';
import {
  branchRuleProvideMock,
  branchRulePropsMock,
  branchRuleWithoutDetailsPropsMock,
  squashOptionMockResponse,
} from '../mock_data';

Vue.use(VueApollo);

describe('Branch rule', () => {
  let wrapper;
  const squashOptionMockRequestHandler = jest.fn().mockResolvedValue(squashOptionMockResponse);

  const createComponent = async (props = {}) => {
    const fakeApollo = createMockApollo([[squashOptionQuery, squashOptionMockRequestHandler]]);

    wrapper = shallowMountExtended(BranchRule, {
      apolloProvider: fakeApollo,
      provide: {
        ...branchRuleProvideMock,
      },
      stubs: {
        ProtectedBadge,
      },
      propsData: { ...branchRulePropsMock, ...props },
    });
    await waitForPromises();
  };

  const findDefaultBadge = () => wrapper.findByText('default');
  const findProtectedBadge = () => wrapper.findByText('protected');
  const findBranchName = () => wrapper.findByText(branchRulePropsMock.name);
  const findProtectionDetailsList = () => wrapper.findByRole('list');
  const findProtectionDetailsListItems = () => wrapper.findAllByRole('listitem');
  const findDetailsButton = () => wrapper.findByText('View details');

  beforeEach(() => createComponent());

  it('renders the branch name', () => {
    expect(findBranchName().exists()).toBe(true);
  });

  describe('badges', () => {
    it('renders both default and protected badges', () => {
      expect(findDefaultBadge().exists()).toBe(true);
      expect(findProtectedBadge().exists()).toBe(true);
    });

    it('does not render default badge if isDefault is set to false', () => {
      createComponent({ isDefault: false });
      expect(findDefaultBadge().exists()).toBe(false);
    });

    it('does not render default badge if branchProtection is null', () => {
      createComponent(branchRuleWithoutDetailsPropsMock);
      expect(findProtectedBadge().exists()).toBe(false);
    });
  });

  it('does not render the protection details list when branchProtection is null', () => {
    createComponent(branchRuleWithoutDetailsPropsMock);
    expect(findProtectionDetailsList().exists()).toBe(false);
  });

  it('renders the protection details list items', () => {
    expect(findProtectionDetailsListItems()).toHaveLength(wrapper.vm.approvalDetails.length);
    expect(findProtectionDetailsListItems().at(0).text()).toBe('Allowed to force push');
    expect(findProtectionDetailsListItems().at(1).text()).toBe(wrapper.vm.pushAccessLevelsText);
    expect(findProtectionDetailsListItems().at(1).text()).toContain('Maintainers');
  });

  it('renders branches count for wildcards', () => {
    createComponent({ name: 'test-*' });
    expect(findProtectionDetailsListItems().at(0).text()).toBe('1 matching branch');
  });

  it('renders a detail button with the correct href', () => {
    const encodedBranchName = encodeURIComponent(branchRulePropsMock.name);

    expect(findDetailsButton().attributes('href')).toBe(
      `${branchRuleProvideMock.branchRulesPath}?branch=${encodedBranchName}`,
    );
  });

  describe('squash settings', () => {
    it('renders squash settings', async () => {
      const branchRuleProps = {
        ...branchRulePropsMock,
      };

      await createComponent(branchRuleProps);
      expect(findProtectionDetailsListItems().at(2).text()).toBe('Squash commits: Encourage');
    });
  });
});
