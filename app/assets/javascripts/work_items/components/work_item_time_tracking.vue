<script>
import {
  GlButton,
  GlModal,
  GlModalDirective,
  GlProgressBar,
  GlSprintf,
  GlTooltipDirective,
} from '@gitlab/ui';
import { outputChronicDuration } from '~/chronic_duration';
import { isPositiveInteger } from '~/lib/utils/number_utils';
import { s__, sprintf } from '~/locale';
import {
  CREATE_TIMELOG_MODAL_ID,
  SET_TIME_ESTIMATE_MODAL_ID,
} from '~/sidebar/components/time_tracking/constants';
import CreateTimelogForm from '~/sidebar/components/time_tracking/create_timelog_form.vue';
import SetTimeEstimateForm from '~/sidebar/components/time_tracking/set_time_estimate_form.vue';
import TimeTrackingReport from '~/sidebar/components/time_tracking/time_tracking_report.vue';

export default {
  i18n: {
    addTimeTrackingMessage: s__(
      'TimeTracking|Add an %{estimateStart}estimate%{estimateEnd} or %{timeSpentStart}time spent%{timeSpentEnd}.',
    ),
  },
  components: {
    TimeTrackingReport,
    CreateTimelogForm,
    GlButton,
    GlModal,
    GlProgressBar,
    GlSprintf,
    SetTimeEstimateForm,
  },
  directives: {
    GlModal: GlModalDirective,
    GlTooltip: GlTooltipDirective,
  },
  inject: ['timeTrackingLimitToHours'],
  props: {
    canUpdate: {
      type: Boolean,
      required: false,
      default: false,
    },
    timeEstimate: {
      type: Number,
      required: false,
      default: 0,
    },
    timelogs: {
      type: Array,
      required: false,
      default: () => [],
    },
    totalTimeSpent: {
      type: Number,
      required: false,
      default: 0,
    },
    workItemId: {
      type: String,
      required: true,
    },
    workItemIid: {
      type: String,
      required: true,
    },
    workItemType: {
      type: String,
      required: true,
    },
  },
  computed: {
    humanTimeEstimate() {
      return outputChronicDuration(this.timeEstimate, this.options);
    },
    humanTotalTimeSpent() {
      return outputChronicDuration(this.totalTimeSpent, this.options) ?? '0h';
    },
    progressBarTooltipText() {
      const timeDifference = this.totalTimeSpent - this.timeEstimate;
      const time = outputChronicDuration(Math.abs(timeDifference), this.options) ?? '0h';
      return isPositiveInteger(timeDifference)
        ? sprintf(s__('TimeTracking|%{time} over'), { time })
        : sprintf(s__('TimeTracking|%{time} remaining'), { time });
    },
    progressBarVariant() {
      return this.timeRemainingPercent > 100 ? 'danger' : 'primary';
    },
    timeEstimateDetails() {
      return {
        timeEstimate: this.timeEstimate,
        humanTimeEstimate: this.humanTimeEstimate,
      };
    },
    timeRemainingPercent() {
      return Math.floor((this.totalTimeSpent / this.timeEstimate) * 100);
    },
    createTimelogModalId() {
      return `${CREATE_TIMELOG_MODAL_ID}-${this.workItemId}`;
    },
    setTimeEstimateModalId() {
      return `${SET_TIME_ESTIMATE_MODAL_ID}-${this.workItemId}`;
    },
    timeTrackingModalId() {
      return `time-tracking-modal-${this.workItemId}`;
    },
    limitToHours() {
      return this.timeTrackingLimitToHours || false;
    },
    options() {
      return {
        hoursPerDay: 8,
        daysPerMonth: 20,
        format: 'short',
        hoursOnly: this.limitToHours,
      };
    },
  },
};
</script>

<template>
  <div data-testid="work-item-time-tracking">
    <div class="gl-flex gl-items-center gl-justify-between">
      <h3 class="gl-heading-5 !gl-mb-2">
        {{ __('Time tracking') }}
      </h3>
      <gl-button
        v-if="canUpdate"
        v-gl-modal="createTimelogModalId"
        v-gl-tooltip.top
        category="tertiary"
        icon="plus"
        size="small"
        data-testid="add-time-entry-button"
        :title="__('Add time entry')"
        :aria-label="__('Add time entry')"
      />
    </div>

    <div
      class="time-tracking-body gl-flex gl-flex-wrap gl-items-center gl-gap-2"
      data-testid="time-tracking-body"
    >
      <template v-if="totalTimeSpent || timeEstimate">
        <div
          class="time-tracking-spent-and-progress gl-flex gl-grow gl-flex-wrap-reverse gl-items-center gl-justify-between gl-gap-2"
        >
          <div class="gl-flex gl-items-center gl-gap-2">
            <span class="gl-text-subtle">{{ s__('TimeTracking|Spent') }}</span>
            <gl-button
              v-if="canUpdate"
              v-gl-modal="timeTrackingModalId"
              v-gl-tooltip="s__('TimeTracking|View time tracking report')"
              variant="link"
              data-testid="view-time-spent-button"
            >
              {{ humanTotalTimeSpent }}
            </gl-button>
            <template v-else>
              {{ humanTotalTimeSpent }}
            </template>
          </div>
          <template v-if="timeEstimate">
            <gl-progress-bar
              v-gl-tooltip="progressBarTooltipText"
              class="time-tracking-progress gl-min-w-11 gl-grow"
              :value="timeRemainingPercent"
              :variant="progressBarVariant"
            />
          </template>
        </div>
        <template v-if="timeEstimate">
          <div class="gl-flex gl-items-center gl-gap-2">
            <span class="gl-text-subtle">{{ s__('TimeTracking|Estimate') }}</span>
            <gl-button
              v-if="canUpdate"
              v-gl-modal="setTimeEstimateModalId"
              v-gl-tooltip="s__('TimeTracking|Set estimate')"
              variant="link"
              data-testid="set-estimate-button"
            >
              {{ humanTimeEstimate }}
            </gl-button>
            <template v-else>
              {{ humanTimeEstimate }}
            </template>
          </div>
        </template>
        <gl-button
          v-else-if="canUpdate"
          v-gl-modal="setTimeEstimateModalId"
          variant="link"
          data-testid="add-estimate-button"
        >
          {{ s__('TimeTracking|Add estimate') }}
        </gl-button>
      </template>
      <span v-else-if="canUpdate" class="gl-text-subtle">
        <gl-sprintf :message="$options.i18n.addTimeTrackingMessage">
          <template #estimate="{ content }">
            <gl-button
              v-gl-modal="setTimeEstimateModalId"
              class="gl-align-baseline"
              variant="link"
              data-testid="add-estimate-button"
            >
              {{ content }}
            </gl-button>
          </template>
          <template #timeSpent="{ content }">
            <gl-button
              v-gl-modal="createTimelogModalId"
              class="gl-align-baseline"
              variant="link"
              data-testid="add-time-spent-button"
            >
              {{ content }}
            </gl-button>
          </template>
        </gl-sprintf>
      </span>
      <span v-else class="gl-text-subtle">
        {{ __('No estimate or time spent') }}
      </span>
    </div>

    <set-time-estimate-form
      :time-tracking="timeEstimateDetails"
      :work-item-id="workItemId"
      :work-item-type="workItemType"
    />

    <create-timelog-form :work-item-id="workItemId" :work-item-type="workItemType" />

    <gl-modal
      :modal-id="timeTrackingModalId"
      data-testid="time-tracking-report-modal"
      hide-footer
      size="lg"
      :title="__('Time tracking report')"
    >
      <time-tracking-report
        :limit-to-hours="limitToHours"
        :timelogs="timelogs"
        :work-item-iid="workItemIid"
      />
    </gl-modal>
  </div>
</template>
