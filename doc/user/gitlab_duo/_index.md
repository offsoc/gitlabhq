---
stage: AI-powered
group: AI Framework
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
description: AI-native features and functionality.
title: GitLab Duo
---

{{< history >}}

- [First GitLab Duo features introduced](https://about.gitlab.com/blog/2023/05/03/gitlab-ai-assisted-features/) in GitLab 16.0.
- [Removed third-party AI setting](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/136144) in GitLab 16.6.
- [Removed support for OpenAI from all GitLab Duo features](https://gitlab.com/groups/gitlab-org/-/epics/10964) in GitLab 16.6.

{{< /history >}}

GitLab Duo is a suite of AI-native features that assist you while you work in GitLab.
These features aim to help increase velocity and solve key pain points across the software development lifecycle.

GitLab Duo features are available in [IDE extensions](../../editor_extensions/_index.md) and the GitLab UI.
Some features are also available as part of [GitLab Duo Chat](../gitlab_duo_chat_examples.md).

- [Get started with GitLab Duo](../get_started/getting_started_gitlab_duo.md).
- [View a walkthrough of GitLab Duo Enterprise features](https://gitlab.navattic.com/duo-enterprise).

## GitLab Duo language models

The language models that are the source for GitLab Duo depend on where you're using it.

- On GitLab.com: GitLab hosts the models and connects to them through the cloud-based AI gateway.
- On GitLab Self-Managed, two options exist:

  - **GitLab** can [host the models and the cloud-based AI gateway](setup.md).
  - **Your organization** can [use GitLab Duo Self-Hosted](../../administration/gitlab_duo_self_hosted/_index.md),
    which means you host the AI gateway and language models. You can use GitLab AI vendor models
    or the other supported language models.
    <i class="fa fa-youtube-play youtube" aria-hidden="true"></i> [Watch overview](https://youtu.be/TQoO3sFnb28?si=w_gFAYLYIzPEbhEl)
    <!-- Video published on 2025-02-20 -->

## Working across the entire software development lifecycle

To improve your workflow across the entire software development lifecycle, try these features:

- [GitLab Duo Chat](../gitlab_duo_chat/_index.md): Write and understand code, get up to speed on the status of projects,
  and learn about GitLab by asking your questions in a chat window.
  <i class="fa fa-youtube-play youtube" aria-hidden="true"></i> [Watch overview](https://www.youtube.com/watch?v=ZQBAuf-CTAY)
  <!-- Video published on 2024-04-18 -->
- [GitLab Duo Workflow](../duo_workflow/_index.md): Automate tasks and help increase productivity in your development workflow.
- [AI Impact Dashboard](../analytics/ai_impact_analytics.md): Measure the AI effectiveness and impact on SDLC metrics.

## Planning work

To improve your workflow while planning work, try these features:

- [Issue Description Generation](../project/issues/managing_issues.md#populate-an-issue-with-issue-description-generation): Generate a more in-depth issue description based on a short summary.
  <i class="fa fa-youtube-play youtube" aria-hidden="true"></i> [Watch overview](https://www.youtube.com/watch?v=-BWBQat7p5M)
  <!-- Video published on 2024-12-18 -->
- [Discussion Summary](../discussions/_index.md#summarize-issue-discussions-with-duo-chat): Summarize lengthy conversations in an issue.
  <i class="fa fa-youtube-play youtube" aria-hidden="true"></i> [Watch overview](https://www.youtube.com/watch?v=IcdxLfTIUgc)
  <!-- Video published on 2024-03-28 -->

## Authoring code

To improve your workflow while authoring code, try these features:

- [Code Suggestions](../project/repository/code_suggestions/_index.md): Generate code and show suggestions as you type.
  <i class="fa fa-youtube-play youtube" aria-hidden="true"></i> [Watch overview](https://youtu.be/ds7SG1wgcVM)
- Code Explanation: Have code explained. View docs for explaining code in:

  - [The IDE](../gitlab_duo_chat/examples.md#explain-selected-code).
  - [A file](../project/repository/code_explain.md).
  - [A merge request](../project/merge_requests/changes.md#explain-code-in-a-merge-request).
  - <i class="fa fa-youtube-play youtube" aria-hidden="true"></i> [Watch overview](https://youtu.be/1izKaLmmaCA?si=O2HDokLLujRro_3O)
    <!-- Video published on 2023-11-18 -->
- [Test Generation](../gitlab_duo_chat/examples.md#write-tests-in-the-ide): Test your code by generating tests.
  <i class="fa fa-youtube-play youtube" aria-hidden="true"></i> [Watch overview](https://www.youtube.com/watch?v=zWhwuixUkYU)
- [Refactor Code](../gitlab_duo_chat/examples.md#refactor-code-in-the-ide): Improve or refactor the selected code.
  <i class="fa fa-youtube-play youtube" aria-hidden="true"></i> [Watch overview](https://youtu.be/oxziu7_mWVk?si=fS2JUO-8doARS169)
- [Fix Code](../gitlab_duo_chat/examples.md#fix-code-in-the-ide): Fix quality problems, like bugs or typos, in the selected code.
- [GitLab Duo for the CLI](../../editor_extensions/gitlab_cli/_index.md#gitlab-duo-for-the-cli): Discover or recall `git` commands.

## Reviewing code

To improve your workflow while reviewing code in merge requests, try these features:

- [Merge Request Summary](../project/merge_requests/duo_in_merge_requests.md#generate-a-description-by-summarizing-code-changes): Generate a description based on the code changes.
  <i class="fa fa-youtube-play youtube" aria-hidden="true"></i> [Watch overview](https://www.youtube.com/watch?v=CKjkVsfyFd8&list=PLFGfElNsQthZGazU1ZdfDpegu0HflunXW)
- [Code Review](../project/merge_requests/duo_in_merge_requests.md#have-gitlab-duo-review-your-code): Review proposed code changes.
- [Code Review Summary](../project/merge_requests/duo_in_merge_requests.md#summarize-a-code-review): Summarize all the comments in a review.
  <i class="fa fa-youtube-play youtube" aria-hidden="true"></i> [Watch overview](https://www.youtube.com/watch?v=Bx6Zajyuy9k)
- [Merge Commit Message Generation](../project/merge_requests/duo_in_merge_requests.md#generate-a-merge-commit-message): Generate commit messages.
  <i class="fa fa-youtube-play youtube" aria-hidden="true"></i> [Watch overview](https://www.youtube.com/watch?v=fUHPNT4uByQ)

## Testing and deploying code

To improve your testing and deployment workflow, try these features:

- [Root Cause Analysis](../gitlab_duo_chat/examples.md#troubleshoot-failed-cicd-jobs-with-root-cause-analysis): Research the root cause for a CI/CD job failure by analyzing the logs.
  <i class="fa fa-youtube-play youtube" aria-hidden="true"></i> [Watch overview](https://www.youtube.com/watch?v=MLjhVbMjFAY&list=PLFGfElNsQthZGazU1ZdfDpegu0HflunXW)

## Securing code

To improve your security, try these features:

- [Vulnerability Explanation](../application_security/vulnerabilities/_index.md#explaining-a-vulnerability): Learn more about vulnerabilities, how they can be exploited, and how to fix them.
  <i class="fa fa-youtube-play youtube" aria-hidden="true"></i> [Watch overview](https://www.youtube.com/watch?v=MMVFvGrmMzw&list=PLFGfElNsQthZGazU1ZdfDpegu0HflunXW)
- [Vulnerability Resolution](../application_security/vulnerabilities/_index.md#vulnerability-resolution): Generate a merge request that addresses a vulnerability.
  <i class="fa fa-youtube-play youtube" aria-hidden="true"></i> [Watch overview](https://www.youtube.com/watch?v=VJmsw_C125E&list=PLFGfElNsQthZGazU1ZdfDpegu0HflunXW)

## Summary of GitLab Duo features

The following features are generally available on GitLab.com, GitLab Self-Managed, and GitLab Dedicated.

They require a Premium or Ultimate subscription and one of the available add-ons.

| Feature | GitLab Duo Core | GitLab Duo Pro | GitLab Duo Enterprise |
|---------|----------|---------|----------------|
| [Code Suggestions](../project/repository/code_suggestions/_index.md) | {{< icon name="check-circle-filled" >}} Yes | {{< icon name="check-circle-filled" >}} Yes | {{< icon name="check-circle-filled" >}} Yes |
| [GitLab Duo Chat](../gitlab_duo_chat/_index.md) in IDEs | {{< icon name="check-circle-filled" >}} Yes | {{< icon name="check-circle-filled" >}} Yes | {{< icon name="check-circle-filled" >}} Yes |
| [Code Explanation](../gitlab_duo_chat/examples.md#explain-selected-code) in IDEs | {{< icon name="check-circle-filled" >}} Yes | {{< icon name="check-circle-filled" >}} Yes | {{< icon name="check-circle-filled" >}} Yes |
| [Refactor Code](../gitlab_duo_chat/examples.md#refactor-code-in-the-ide) in IDEs | {{< icon name="check-circle-filled" >}} Yes | {{< icon name="check-circle-filled" >}} Yes | {{< icon name="check-circle-filled" >}} Yes |
| [Fix Code](../gitlab_duo_chat/examples.md#fix-code-in-the-ide) in IDEs | {{< icon name="check-circle-filled" >}} Yes | {{< icon name="check-circle-filled" >}} Yes | {{< icon name="check-circle-filled" >}} Yes |
| [Test Generation](../gitlab_duo_chat/examples.md#write-tests-in-the-ide) in IDEs | {{< icon name="check-circle-filled" >}} Yes | {{< icon name="check-circle-filled" >}} Yes | {{< icon name="check-circle-filled" >}} Yes |
| [GitLab Duo Chat](../gitlab_duo_chat/_index.md) in GitLab UI | {{< icon name="dash-circle" >}} No | {{< icon name="check-circle-filled" >}} Yes | {{< icon name="check-circle-filled" >}} Yes |
| [Code Explanation](../project/repository/code_explain.md) in GitLab UI | {{< icon name="dash-circle" >}} No | {{< icon name="check-circle-filled" >}} Yes | {{< icon name="check-circle-filled" >}} Yes |
| [Discussion Summary](../discussions/_index.md#summarize-issue-discussions-with-duo-chat) | {{< icon name="dash-circle" >}} No | {{< icon name="dash-circle" >}} No | {{< icon name="check-circle-filled" >}} Yes |
| [GitLab Duo for the CLI](../../editor_extensions/gitlab_cli/_index.md#gitlab-duo-for-the-cli) | {{< icon name="dash-circle" >}} No | {{< icon name="dash-circle" >}} No | {{< icon name="check-circle-filled" >}} Yes |
| [Merge Commit Message Generation](../project/merge_requests/duo_in_merge_requests.md#generate-a-merge-commit-message) | {{< icon name="dash-circle" >}} No | {{< icon name="dash-circle" >}} No | {{< icon name="check-circle-filled" >}} Yes |
| [Root Cause Analysis](../gitlab_duo_chat/examples.md#troubleshoot-failed-cicd-jobs-with-root-cause-analysis) | {{< icon name="dash-circle" >}} No | {{< icon name="dash-circle" >}} No | {{< icon name="check-circle-filled" >}} Yes |
| [Vulnerability Explanation](../application_security/vulnerabilities/_index.md#explaining-a-vulnerability) | {{< icon name="dash-circle" >}} No | {{< icon name="dash-circle" >}} No | {{< icon name="check-circle-filled" >}} Yes |
| [Vulnerability Resolution](../application_security/vulnerabilities/_index.md#vulnerability-resolution) | {{< icon name="dash-circle" >}} No | {{< icon name="dash-circle" >}} No | {{< icon name="check-circle-filled" >}} Yes |
| [AI Impact Dashboard](../analytics/ai_impact_analytics.md) | {{< icon name="dash-circle" >}} No | {{< icon name="dash-circle" >}} No | {{< icon name="check-circle-filled" >}} Yes |

In addition:

- All GitLab Duo Core and Pro features include generally available support for
 [GitLab Duo Self-Hosted](../../administration/gitlab_duo_self_hosted/_index.md).
- All GitLab Duo Enterprise-only features include beta support for GitLab Duo Self-Hosted.

### Beta and experimental features

The following features are not generally available.

They require a Premium or Ultimate subscription and one of the available add-ons.

| Feature | GitLab Duo Core | GitLab Duo Pro | GitLab Duo Enterprise | GitLab.com | GitLab Self-Managed | GitLab Dedicated | GitLab Duo Self-Hosted |
|---------|----------|---------|----------------|-----------|-------------|-----------|------------------------|
| [Code Review Summary](../project/merge_requests/duo_in_merge_requests.md#summarize-a-code-review) | {{< icon name="dash-circle" >}} No | {{< icon name="dash-circle" >}} No | {{< icon name="check-circle-filled" >}} Yes | Experiment | Experiment | {{< icon name="dash-circle" >}} No | Experiment |
| [Issue Description Generation](../project/issues/managing_issues.md#populate-an-issue-with-issue-description-generation) | {{< icon name="dash-circle" >}} No | {{< icon name="dash-circle" >}} No | {{< icon name="check-circle-filled" >}} Yes | Experiment | {{< icon name="dash-circle" >}} No | {{< icon name="dash-circle" >}} No | N/A |
| [Code Review](../project/merge_requests/duo_in_merge_requests.md#have-gitlab-duo-review-your-code) | {{< icon name="dash-circle" >}} No | {{< icon name="dash-circle" >}} No | {{< icon name="check-circle-filled" >}} Yes | Beta | Beta | Beta | N/A |
| [Merge Request Summary](../project/merge_requests/duo_in_merge_requests.md#generate-a-description-by-summarizing-code-changes) | {{< icon name="dash-circle" >}} No | {{< icon name="dash-circle" >}} No | {{< icon name="check-circle-filled" >}} Yes | Beta | Beta | {{< icon name="dash-circle" >}} No | Beta |

[GitLab Duo Workflow](../duo_workflow/_index.md) is in private beta, does not require an add-on, and is not supported for GitLab Duo Self-Hosted.
