## Contributor guidelines
We'd love for you to contribute to this repository. Before you start, we'd like you to take a look and follow these guidelines:
  - [Submitting an Issue](#submitting-an-issue)
  - [Creating a pull request](#creating-a-pull-request)
  - [Coding Rules](#coding-rules)
    - [Swift style](#swift-style)
    - [Whitespace](#whitespace)
  - [Commits](#commits)

### Submitting an Issue
If you find a bug in the source code or a mistake in the documentation, you can help us by submitting an issue to our repository. Before you submit your issue, search open and closed issues, maybe your question was already answered.

### Creating a pull request
* All pull requests must be associated with a specific Issue. If an issue doesn't exist please first create it.
* Before you submit your pull request, search the repository for an open or closed Pull Request that relates to your submission. You don't want to duplicate effort. 
* For commiting in your Pull Request, you can checkout [Commits](#commits) for more.

### Coding Rules

#### Swift style
* Swift code should generally follow the conventions listed at https://github.com/raywenderlich/swift-style-guide.
  * Exception: we use 4-space indentation instead of 2.
  * This is a loose standard. We do our best to follow this style.
  * Run `Scripts/swift-format.sh` to format your code automatically.

#### Whitespace
* New code should not contain any trailing whitespace.
* We recommend enabling both the "Automatically trim trailing whitespace" and "Including whitespace-only lines" preferences in Xcode (under Text Editing).
* <code>git rebase --whitespace=fix</code> can also be used to remove whitespace from your commits before issuing a pull request.

### Commits
* Each commit should have a single clear purpose. If a commit contains multiple unrelated changes, those changes should be split into separate commits.
* If a commit requires another commit to build properly, those commits should be squashed.
* Follow-up commits for any review comments should be squashed. Do not include "Fixed PR comments", merge commits, or other "temporary" commits in pull requests.

### Tests
* Automated tests are important. You should write tests! This is how we guard the code against regressions.
* New code should include tests that provide coverage for the functionality of the code.
* Bug fixes should include tests that prevent the bug from re-occuring in the future.
* It is everyone's responsibility to write tests, and as a code reviewer, you should expect PRs to include tests.
* Prefer smaller unit tests (see ClientTests) over larger integration tests (see XCUITests).
* Prefer XCUITests over UITests.

### Privileged links
At times core contributors and Neeva employees will link to external resources that are privileged and not publicly accessible. We do our best to prefix these links with a lock emoji (🔒).
