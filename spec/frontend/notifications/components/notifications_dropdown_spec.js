import { GlButton, GlButtonGroup, GlCollapsibleListbox, GlListboxItem } from '@gitlab/ui';
import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import { createMockDirective, getBinding } from 'helpers/vue_mock_directive';
import waitForPromises from 'helpers/wait_for_promises';
import { HTTP_STATUS_NOT_FOUND, HTTP_STATUS_OK } from '~/lib/utils/http_status';
import CustomNotificationsModal from '~/notifications/components/custom_notifications_modal.vue';
import NotificationsDropdown from '~/notifications/components/notifications_dropdown.vue';

const mockDropdownItems = ['global', 'watch', 'participating', 'mention', 'disabled'];
const mockToastShow = jest.fn();

describe('NotificationsDropdown', () => {
  let wrapper;
  let mockAxios;

  function createComponent(injectedProperties = {}) {
    return mountExtended(NotificationsDropdown, {
      stubs: {
        GlButtonGroup,
        GlButton,
        GlCollapsibleListbox,
        CustomNotificationsModal,
      },
      directives: {
        GlTooltip: createMockDirective('gl-tooltip'),
      },
      provide: {
        dropdownItems: mockDropdownItems,
        initialNotificationLevel: 'global',
        ...injectedProperties,
      },
      mocks: {
        $toast: {
          show: mockToastShow,
        },
      },
    });
  }

  const findDropdown = () => wrapper.findComponent(GlCollapsibleListbox);
  const findSplitIcon = () => wrapper.findByTestId('notification-split-icon');
  const findAllNotificationsDropdownItems = () => wrapper.findAllComponents(GlListboxItem);
  const findListboxItemAt = (index) => findAllNotificationsDropdownItems().at(index);
  const findListboxItem = (value) => wrapper.findByTestId(`listbox-item-${value}`);
  const findNotificationsModal = () => wrapper.findComponent(CustomNotificationsModal);
  const tooltipTitlePrefix = 'Notification setting';

  const clickListboxItem = async (value) => {
    const dropdownItem = findListboxItem(value);
    await dropdownItem.trigger('click');

    await waitForPromises();
  };

  beforeEach(() => {
    gon.api_version = 'v4';
    mockAxios = new MockAdapter(axios);
  });

  afterEach(() => {
    mockAxios.restore();
  });

  describe('template', () => {
    describe('when notification level is "custom"', () => {
      beforeEach(() => {
        wrapper = createComponent({
          initialNotificationLevel: 'custom',
        });
      });

      it('renders split dropdown', () => {
        expect(findDropdown().props().icon).toBe('');
        expect(findSplitIcon().exists()).toBe(true);
      });

      it('shows the button text when showLabel is true', () => {
        wrapper = createComponent({
          initialNotificationLevel: 'custom',
          showLabel: true,
        });

        expect(findDropdown().props().toggleText).toBe('Custom');
      });

      it('shows the tooltip text when showLabel is false', () => {
        wrapper = createComponent({
          initialNotificationLevel: 'custom',
          showLabel: false,
        });

        expect(findDropdown().props().toggleText).toBe(`${tooltipTitlePrefix} - Custom`);
      });

      it('opens the modal when the user clicks the button', async () => {
        jest.spyOn(axios, 'put');
        mockAxios.onPut('/api/v4/notification_settings').reply(HTTP_STATUS_OK, {});

        wrapper = createComponent({
          initialNotificationLevel: 'custom',
        });

        await findSplitIcon().vm.$emit('click');

        expect(findNotificationsModal().props().visible).toBe(true);
      });
    });

    describe('when notification level is not "custom"', () => {
      beforeEach(() => {
        wrapper = createComponent({
          initialNotificationLevel: 'global',
        });
      });

      it('renders unified dropdown', () => {
        expect(findDropdown().props().icon).toBe('notifications');
        expect(findSplitIcon().exists()).toBe(false);
      });

      it('shows the button text when showLabel is true', () => {
        wrapper = createComponent({
          showLabel: true,
        });

        expect(findDropdown().props().toggleText).toBe('Global');
      });

      it('shows the tooltip text when showLabel is false', () => {
        wrapper = createComponent({
          showLabel: false,
        });

        expect(findDropdown().props().toggleText).toBe(`${tooltipTitlePrefix} - Global`);
      });
    });

    describe('button tooltip', () => {
      it.each`
        level              | title
        ${'global'}        | ${'Global'}
        ${'watch'}         | ${'Watch'}
        ${'participating'} | ${'Participate'}
        ${'mention'}       | ${'On mention'}
        ${'disabled'}      | ${'Disabled'}
        ${'custom'}        | ${'Custom'}
      `(`renders "${tooltipTitlePrefix} - $title" for "$level" level`, ({ level, title }) => {
        wrapper = createComponent({
          initialNotificationLevel: level,
        });

        const tooltipElement = wrapper.findByTestId('notification-dropdown');
        const tooltip = getBinding(tooltipElement.element, 'gl-tooltip');

        expect(tooltip.value.title).toBe(`${tooltipTitlePrefix} - ${title}`);
      });
    });

    describe('button icon', () => {
      beforeEach(() => {
        wrapper = createComponent({
          initialNotificationLevel: 'disabled',
        });
      });

      it('renders the "notifications-off" icon when notification level is "disabled"', () => {
        expect(findDropdown().props('icon')).toBe('notifications-off');
      });

      it('renders the "notifications" icon when notification level is not "disabled"', () => {
        wrapper = createComponent();

        expect(findDropdown().props('icon')).toBe('notifications');
      });
    });

    describe('dropdown items', () => {
      it.each`
        dropdownIndex | level              | title            | description
        ${0}          | ${'global'}        | ${'Global'}      | ${'Use your global notification setting'}
        ${1}          | ${'watch'}         | ${'Watch'}       | ${'You will receive notifications for most activity'}
        ${2}          | ${'participating'} | ${'Participate'} | ${'You will only receive notifications for items you have participated in'}
        ${3}          | ${'mention'}       | ${'On mention'}  | ${'You will receive notifications only for comments in which you were @mentioned'}
        ${4}          | ${'disabled'}      | ${'Disabled'}    | ${'You will not get any notifications via email'}
        ${5}          | ${'custom'}        | ${'Custom'}      | ${'You will only receive notifications for items you have participated in and the events you choose'}
      `('displays "$title" and "$description"', ({ dropdownIndex, title, description }) => {
        wrapper = createComponent();

        expect(
          findAllNotificationsDropdownItems().at(dropdownIndex).find('span.gl-font-bold').text(),
        ).toBe(title);
        expect(
          findAllNotificationsDropdownItems().at(dropdownIndex).find('span.gl-text-subtle').text(),
        ).toBe(description);
      });
    });
  });

  describe('when selecting an item', () => {
    beforeEach(() => {
      jest.spyOn(axios, 'put');
    });

    it.each`
      projectId | groupId | endpointUrl                                   | endpointType               | condition
      ${1}      | ${null} | ${'/api/v4/projects/1/notification_settings'} | ${'project notifications'} | ${'a projectId is given'}
      ${null}   | ${1}    | ${'/api/v4/groups/1/notification_settings'}   | ${'group notifications'}   | ${'a groupId is given'}
      ${null}   | ${null} | ${'/api/v4/notification_settings'}            | ${'global notifications'}  | ${'when neither projectId nor groupId are given'}
    `(
      'calls the $endpointType endpoint when $condition',
      async ({ projectId, groupId, endpointUrl }) => {
        wrapper = createComponent({
          projectId,
          groupId,
        });

        await clickListboxItem('watch');

        expect(axios.put).toHaveBeenCalledWith(endpointUrl, {
          level: 'watch',
        });
      },
    );

    it('updates the selectedNotificationLevel and marks the item as selected', async () => {
      mockAxios.onPut('/api/v4/notification_settings').reply(HTTP_STATUS_OK, {});
      wrapper = createComponent();

      const dropdownItem = findListboxItemAt(1);

      await clickListboxItem('watch');

      expect(wrapper.vm.selectedNotificationLevel).toBe('watch');
      expect(dropdownItem.props().isSelected).toBe(true);
    });

    it("won't update the selectedNotificationLevel and shows a toast message when the request fails and", async () => {
      mockAxios.onPut('/api/v4/notification_settings').reply(HTTP_STATUS_NOT_FOUND, {});
      wrapper = createComponent();

      await clickListboxItem('watch');

      expect(wrapper.vm.selectedNotificationLevel).toBe('global');
      expect(mockToastShow).toHaveBeenCalledWith(
        'An error occurred while updating the notification settings. Please try again.',
      );
    });

    it('opens the modal when the user clicks on the "Custom" dropdown item', async () => {
      mockAxios.onPut('/api/v4/notification_settings').reply(HTTP_STATUS_OK, {});
      wrapper = createComponent();

      await clickListboxItem('custom');

      expect(findNotificationsModal().props().visible).toBe(true);
    });
  });
});
