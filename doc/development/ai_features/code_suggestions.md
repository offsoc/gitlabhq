---
stage: Create
group: Code Creation
info: Any user with at least the Maintainer role can merge updates to this content. For details, see https://docs.gitlab.com/ee/development/development_processes.html#development-guidelines-review.
description: Code Suggestions documentation for developers interested in contributing features or bugfixes.
title: Code Suggestions development guidelines
---

## Code Suggestions development setup

The recommended setup for locally developing and debugging Code Suggestions is to have all 3 different components running:

- IDE Extension (for example, GitLab Workflow extension for VS Code).
- Main application configured correctly (for example, GDK).
- [AI gateway](https://gitlab.com/gitlab-org/modelops/applied-ml/code-suggestions/ai-assist).

This should enable everyone to locally see how any change made in an IDE is sent to the main application to be transformed into a prompt before being sent to the respective model.

### Setup instructions

1. Install and locally run the [GitLab Workflow extension for VS Code](https://gitlab.com/gitlab-org/gitlab-vscode-extension/-/blob/main/CONTRIBUTING.md#configuring-development-environment):
   1. Add the `"gitlab.debug": true` info to the Code Suggestions development config:
      1. In VS Code, go to the Extensions page and find "GitLab Workflow" in the list.
      1. Open the extension settings by clicking a small cog icon and select "Extension Settings" option.
      1. Check a "GitLab: Debug" checkbox.
   1. If you'd like to test that Code Suggestions is working from inside the GitLab Workflow extension for VS Code, then follow the [authenticate with GitLab steps](../../editor_extensions/visual_studio_code/setup.md#authenticate-with-gitlab) with your GDK inside the new window of VS Code that pops up when you run the "Run and Debug" command.
      - Once you complete the steps below, to test you are hitting your local `/code_suggestions/completions` endpoint and not production, follow these steps:
        1. Inside the new window, in the built in terminal select the "Output" tab then "GitLab Language Server" from the drop down menu on the right.
        1. Open a new file inside of this VS Code window and begin typing to see Code Suggestions in action.
        1. You will see completion request URLs being fetched that match the Git remote URL for your GDK.

1. Main Application (GDK):
   1. Install the [GitLab Development Kit](https://gitlab.com/gitlab-org/gitlab-development-kit/-/blob/main/doc/index.md#one-line-installation).
   1. Enable Feature Flag `ai_duo_code_suggestions_switch`:
      1. In your terminal, go to your `gitlab-development-kit` > `gitlab` directory.
      1. Run `gdk rails console` or `bundle exec rails c` to start a Rails console.
      1. [Enable the Feature Flag](../../administration/feature_flags.md#enable-or-disable-the-feature) for the Code Suggestions tokens API by calling `Feature.enable(:ai_duo_code_suggestions_switch)` from the console.
   1. [Setup AI gateway](_index.md#required-install-ai-gateway).
   1. Run your GDK server with `gdk start` if it's not already running.

### Setup instructions to use staging AI gateway

When testing interactions with the AI gateway, you might want to integrate your local GDK
with the deployed staging AI gateway. To do this:

1. You need a cloud staging license that has the Code Suggestions add-on,
   because add-ons are enabled on staging. Follow [these instructions](#setup-instructions-to-use-gdk-with-the-code-suggestions-add-on) to add the add-on to your license (you can reach out to `#s_fulfillment_engineering` if you have any problems).
   See this [handbook page](https://handbook.gitlab.com/handbook/engineering/developer-onboarding/#working-on-gitlab-ee-developer-licenses) for how to request a license for local development.
1. Set environment variables in your GDK to point customers-dot to staging, and the AI gateway to staging. You can refer to [this documentation](https://gitlab.com/gitlab-org/gitlab-development-kit/-/blob/main/doc/runit.md#using-environment-variables)
   to set the environment variables in your GDK:

   ```shell
   export GITLAB_LICENSE_MODE=test
   export CUSTOMER_PORTAL_URL=https://customers.staging.gitlab.com
   ```

1. Set the AI gateway URL in a Rails console:

   ```ruby
   Ai::Setting.instance.update!(ai_gateway_url: 'https://cloud.staging.gitlab.com/ai')
   ```

1. Restart the GDK.
1. Ensure you followed the necessary [steps to enable the Code Suggestions feature](../../user/project/repository/code_suggestions/_index.md).
1. Test out the Code Suggestions feature by opening the Web IDE for a project.

### Setup instructions to use GDK with the Code Suggestions Add-on

#### Option 1 - Recommended

1. Ensure that you have a [GitLab Team Member License](https://handbook.gitlab.com/handbook/engineering/developer-onboarding/#working-on-gitlab-ee-developer-licenses) and that it is [activated](../../administration/license_file.md).
1. Follow the [Setup and Run GDK](_index.md#set-up-and-run-gdk) guide under the AI Features doc.

#### Option 2

You can set up Duo on your GDK by going through CustomersDot. This is a more complex process, but it more accurately reflects the GitLab Self-Managed setup of our customers.

<details>
<summary>Expand for alternate setup</summary>

1. Add a **Self-Managed Ultimate** subscription with a [Duo Pro subscription add-on](../../subscriptions/subscription-add-ons.md) to your GDK instance.

   1. Sign in to the [staging Customers Portal](https://customers.staging.gitlab.com) by selecting the **Continue with GitLab.com account** button.
      If you do not have an existing account, you are prompted to create one.
   1. If you do not have an existing cloud activation code, visit the **Self-Managed Ultimate Subscription** page using the [buy subscription flow link](https://gitlab.com/gitlab-org/customers-gitlab-com/-/blob/8aa922840091ad5c5d96ada43d0065a1b6198841/doc/flows/buy_subscription.md).
   1. Purchase the subscription using [a test credit card](https://gitlab.com/gitlab-org/customers-gitlab-com/#testing-credit-card-information).
   1. Once you have a subscription, on the subscription card, select the ellipse menu **...** > **Buy Duo Pro add-on**.
   1. Use the previously saved credit card information, and the same number of seats as in the subscription.

   After this step is complete, you will have an activation code for an _Self-Managed Ultimate subscription with a Duo Pro add-on_.

1. Follow the [activation instructions](https://gitlab.com/gitlab-org/customers-gitlab-com/-/blob/main/doc/license/cloud_license.md?ref_type=heads#testing-activation):

   1. Set environment variables.

      ```shell
      export GITLAB_LICENSE_MODE=test
      export CUSTOMER_PORTAL_URL=https://customers.staging.gitlab.com
      export GITLAB_SIMULATE_SAAS=0
      ```

      On a non-GDK instance, you can set the variables using `gitlab_rails['env']` in the `gitlab.rb` file:

      ```shell
      gitlab_rails['env'] = {
        'GITLAB_LICENSE_MODE' => 'test',
        'CUSTOMER_PORTAL_URL' => 'https://customers.staging.gitlab.com'
      }
      ```

   1. Set the AI gateway URL in a Rails console:

      ```ruby
       Ai::Setting.instance.update!(ai_gateway_url: 'https://cloud.staging.gitlab.com/ai')
      ```

   1. Restart your GDK.
   1. Go to `/admin/subscription`.
   1. Optional. Remove any active license.
   1. Add the new activation code.

1. Inside your GDK, navigate to **Admin area** > **GitLab Duo Pro**, go to `/admin/code_suggestions`
1. Filter users to find `root` and click the toggle to assign a GitLab Duo Pro add-on seat to the root user.

</details>

### Bulk assign users to Duo Pro/Duo Enterprise add-on

After purchasing the Duo add-on, existing eligible users can be assigned/un-assigned to the Duo `add_on_purchase` in bulk. There are a few ways to perform this action, that apply for both GitLab.com and GitLab Self-Managed instances,

1. [Duo users management UI](../../subscriptions/subscription-add-ons.md#assign-gitlab-duo-seats)
1. [GraphQL endpoint](../../api/graphql/assign_gitlab_duo_seats.md)
1. [Rake task](../../administration/raketasks/user_management.md#bulk-assign-users-to-gitlab-duo)

The above methods make use of the [BulkAssignService](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/app/services/gitlab_subscriptions/duo/bulk_assign_service.rb)/[BulkUnassignService](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/app/services/gitlab_subscriptions/duo/bulk_unassign_service.rb), which evaluates eligibility criteria preliminarily before assigning/un-assigning the passed users in a single SQL operation.

### Setting up Duo on your **staging** GitLab.com account

Please refer to [Instructions for setting up Duo add-ons on your **staging** GitLab.com account](ai_development_license.md).

### Video demonstrations of installing and using Code Suggestions in IDEs

<i class="fa fa-youtube-play youtube" aria-hidden="true"></i>
For more guidance, see the following video demonstrations of installing
and using Code Suggestions in:

- [VS Code](https://www.youtube.com/watch?v=bJ7g9IEa48I).
  <!-- Video published on 2024-09-03 -->
- [IntelliJ IDEA](https://www.youtube.com/watch?v=WE9agcnGT6A).
  <!-- Video published on 2024-09-03 -->
