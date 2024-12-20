import { shallowMount } from '@vue/test-utils';
import { GlCollapsibleListbox, GlListboxItem, GlIcon } from '@gitlab/ui';
import BranchDropdown from '~/search/sidebar/components/shared/branch_dropdown.vue';
import waitForPromises from 'helpers/wait_for_promises';
import { DEFAULT_DEBOUNCE_AND_THROTTLE_MS } from '~/lib/utils/constants';

import { mockSourceBranches } from 'jest/search/mock_data';

describe('BranchDropdown', () => {
  let wrapper;

  const defaultProps = {
    sourceBranches: mockSourceBranches,
    errors: [],
    headerText: 'Source branch',
    searchBranchText: 'Search source branch',
    selectedBranch: 'master',
    icon: 'branch',
    isLoading: false,
  };

  const createComponent = (props = {}, options = {}) => {
    wrapper = shallowMount(BranchDropdown, {
      propsData: {
        ...defaultProps,
        ...props,
      },
      stubs: {
        GlCollapsibleListbox,
        GlIcon,
      },
      ...options,
    });
  };

  const findGlCollapsibleListbox = () => wrapper.findComponent(GlCollapsibleListbox);
  const findGlListboxItems = () => wrapper.findAllComponents(GlListboxItem);
  const findErrorMessages = () => wrapper.findAll('[data-testid="branch-dropdown-error-list"]');

  describe('when nothing is selected', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the GlCollapsibleListbox component with correct props', () => {
      const toggleClass = [
        {
          '!gl-shadow-inner-1-red-500': undefined,
          'gl-font-monospace': true,
        },
        'gl-mb-0',
      ];

      // This is a workaround for "Property or method `nodeType` is not defined"
      // https://docs.gitlab.com/ee/development/fe_guide/troubleshooting.html#property-or-method-nodetype-is-not-defined-but-youre-not-using-nodetype-anywhere
      // usual workourounds didn't work so I had to do following:

      const props = findGlCollapsibleListbox().props();

      expect(props.selected).toBe('master');
      expect(props.headerText).toBe('Source branch');
      expect(props.items).toMatchObject(mockSourceBranches);
      expect(props.noResultsText).toBe('No results found');
      expect(props.searching).toBe(false);
      expect(props.searchPlaceholder).toBe('Search source branch');
      expect(props.toggleClass).toMatchObject(toggleClass);
      expect(props.toggleText).toBe('Search source branch');
      expect(props.icon).toBe('branch');
      expect(props.loading).toBe(false);
      expect(props.resetButtonLabel).toBe('Reset');
    });

    it('renders error messages when errors prop is passed', async () => {
      const errors = ['Error 1', 'Error 2'];
      createComponent({ errors });

      await waitForPromises();

      const errorMessages = findErrorMessages();

      expect(errorMessages.length).toBe(errors.length);
      errorMessages.wrappers.forEach((errorWrapper, index) => {
        expect(errorWrapper.text()).toContain(errors[index]);
      });
    });

    it('search filters items', async () => {
      findGlCollapsibleListbox().vm.$emit('search', 'fea');
      jest.advanceTimersByTime(DEFAULT_DEBOUNCE_AND_THROTTLE_MS);
      await waitForPromises();

      expect(findGlListboxItems()).toHaveLength(1);
    });

    it('emits hide', () => {
      findGlCollapsibleListbox().vm.$emit('hidden');

      expect(wrapper.emitted('hide')).toStrictEqual([[]]);
    });

    it('emits selected', () => {
      findGlCollapsibleListbox().vm.$emit('select', 'main');

      expect(wrapper.emitted('selected')).toStrictEqual([['main']]);
    });

    it('emits reset', () => {
      findGlCollapsibleListbox().vm.$emit('reset');

      expect(wrapper.emitted('reset')).toStrictEqual([[]]);
    });

    it('emits hide and selected if there are no results but query contains strings', async () => {
      findGlCollapsibleListbox().vm.$emit('search', 'ttteeeeessssssttttt');
      jest.advanceTimersByTime(DEFAULT_DEBOUNCE_AND_THROTTLE_MS);
      await waitForPromises();

      expect(findGlListboxItems()).toHaveLength(0);

      findGlCollapsibleListbox().vm.$emit('hidden');

      expect(wrapper.emitted('hide')).toStrictEqual([[]]);
      expect(wrapper.emitted('selected')).toStrictEqual([['ttteeeeessssssttttt']]);
    });
  });
});
