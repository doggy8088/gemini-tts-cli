# Publishing gemini-tts-cli to Scoop

This guide explains how to publish the `gemini-tts-cli` tool to the Scoop package manager for Windows.

## Prerequisites

1.  **Scoop Installed:** Ensure you have Scoop installed. If not, follow the instructions at [scoop.sh](https://scoop.sh/).
2.  **`gemini-tts-cli.json` Manifest:** This repository now contains a `gemini-tts-cli.json` file in its root. This is the Scoop manifest file. The GitHub Actions workflow in this repository is configured to automatically update this manifest with the latest version, download URLs, and SHA256 hashes whenever a new release is tagged (e.g., `v0.2.1`).

## Understanding Scoop Buckets

Scoop installs apps from "buckets," which are essentially Git repositories containing JSON manifest files for each app.

## Option 1: Creating Your Own Scoop Bucket (Recommended for Initial Publishing)

This is the quickest way to make your tool available via Scoop and gives you full control.

1.  **Create a New GitHub Repository for Your Bucket:**
    *   Go to GitHub and create a new public repository. For example, name it `my-scoop-bucket` (replace `my` with your GitHub username or organization name, e.g., `doggy8088-scoop`).
    *   This repository will host the manifest(s) for your tools.

2.  **Add the Manifest to Your Bucket Repository:**
    *   Clone your newly created bucket repository to your local machine.
    *   Copy the `gemini-tts-cli.json` file from the root of the `gemini-tts-cli` tool repository into the root of your local bucket repository clone.
    *   Commit and push this file to your bucket repository on GitHub.
        ```bash
        cd path/to/your/local/my-scoop-bucket
        # (copy gemini-tts-cli.json here)
        git add gemini-tts-cli.json
        git commit -m "Add gemini-tts-cli manifest"
        git push origin main # or master, depending on your default branch
        ```

3.  **Users Add Your Bucket:**
    *   Users can now add your bucket to their Scoop installation:
        ```bash
        scoop bucket add <your-bucket-name> https://github.com/<your-github-username>/<your-bucket-repo-name>.git
        # Example:
        # scoop bucket add doggy8088-scoop https://github.com/doggy8088/doggy8088-scoop.git
        ```
        *(The `<your-bucket-name>` is a local alias users choose, but it's good practice to suggest one related to your GitHub repo name).*

4.  **Users Install Your Tool:**
    *   Once the bucket is added, users can install `gemini-tts-cli`:
        ```bash
        scoop install <your-bucket-name>/gemini-tts-cli
        # Or, if the app name is unique across all their added buckets:
        # scoop install gemini-tts-cli
        ```

5.  **Maintaining Your Bucket:**
    *   Whenever you release a new version of `gemini-tts-cli`, the `gemini-tts-cli.json` in *this* tool's repository will be updated automatically by the GitHub workflow.
    *   You will need to **manually copy this updated `gemini-tts-cli.json` file to your separate Scoop bucket repository** and push the changes there.
    *   Alternatively, for a more automated approach, you could set up a GitHub Action in your bucket repository to periodically pull the latest `gemini-tts-cli.json` from this tool's repository.

## Option 2: Submitting to an Official or Community Scoop Bucket

This makes your tool more discoverable but involves a review process. The main official buckets are `Main` and `Extras`. Your CLI tool might be a candidate for `Main` if it's widely applicable, or `Extras` otherwise.

1.  **Choose a Bucket and Read Contribution Guidelines:**
    *   **Main Bucket:** [Scoop/Main](https://github.com/ScoopInstaller/Main) - For very common, stable CLI tools.
    *   **Extras Bucket:** [Scoop/Extras](https://github.com/ScoopInstaller/Extras) - For GUI apps and less common CLI tools.
    *   Review their `CONTRIBUTING.md` file carefully.

2.  **Fork the Bucket Repository:**
    *   Go to the GitHub page of the chosen bucket (e.g., `ScoopInstaller/Extras`) and click "Fork."

3.  **Clone Your Fork:**
    *   Clone your forked repository to your local machine:
        ```bash
        git clone https://github.com/<your-github-username>/<bucket-repo-name>.git
        # Example: git clone https://github.com/doggy8088/Extras.git
        ```

4.  **Add Your Manifest:**
    *   Copy the `gemini-tts-cli.json` file from this tool's repository into the root of your cloned fork (or a specific subfolder if the bucket's contribution guidelines specify one).

5.  **Test Locally (Crucial):**
    *   Add your forked bucket locally to test *your version* of the manifest:
        ```bash
        # cd path/to/your/local/forked/bucket_clone
        scoop bucket add my-test-fork .
        # (The '.' adds the current directory as a bucket named 'my-test-fork')
        ```
    *   Test installation:
        ```bash
        scoop install my-test-fork/gemini-tts-cli
        ```
    *   Verify it works as expected.
    *   Test uninstallation:
        ```bash
        scoop uninstall my-test-fork/gemini-tts-cli
        ```
    *   After testing, remove your test bucket:
        ```bash
        scoop bucket rm my-test-fork
        ```

6.  **Commit and Push to Your Fork:**
    *   Navigate to your local forked bucket repository.
    *   Commit the new manifest file:
        ```bash
        git add gemini-tts-cli.json
        git commit -m "Add gemini-tts-cli manifest v0.2.0" # Be specific with version
        ```
    *   Push to your fork on GitHub:
        ```bash
        git push origin main # or the branch you're working on
        ```

7.  **Create a Pull Request (PR):**
    *   Go to your forked repository on GitHub.
    *   You should see a prompt to "Compare & pull request." Click it.
    *   Ensure the base repository is the official bucket (e.g., `ScoopInstaller/Extras`) and the head repository is your fork.
    *   Write a clear title and description for your PR, mentioning that the manifest uses GitHub releases and has `checkver` and `autoupdate` configured.
    *   Submit the PR.

8.  **Address Feedback:**
    *   Bucket maintainers will review your submission. They might request changes or ask questions. Respond promptly and make any necessary adjustments.

## Testing the Manifest Locally (Before Any Submission)

You can always test your `gemini-tts-cli.json` file directly without adding it to a full bucket:

1.  **Using a local file path:**
    ```bash
    scoop install path/to/your/gemini-tts-cli.json
    ```
2.  **Using the raw GitHub URL to the manifest in your tool's repository:**
    ```bash
    scoop install https://raw.githubusercontent.com/doggy8088/gemini-tts-cli/main/gemini-tts-cli.json
    # (Ensure 'main' is your default branch name if not, adjust it)
    ```

This is very useful for quick checks. After testing, uninstall it: `scoop uninstall gemini-tts-cli`.

## Manifest Upkeep (When in an Official/Community Bucket)

*   The `checkver` field in `gemini-tts-cli.json` tells Scoop how to find the latest version of your tool from its GitHub releases.
*   The `autoupdate` field tells Scoop how to construct the download URLs and (hopefully) find the hashes for new versions.
*   When you publish a new release of `gemini-tts-cli` on GitHub, Scoop users should eventually be able to run `scoop update gemini-tts-cli` to get it.
*   The GitHub Action we set up updates `gemini-tts-cli.json` in *this* repository, which `checkver` in the *bucket's copy* of the manifest will look at.
*   If the `autoupdate` configuration for hashes (`"hash": { "url": "$url.sha256", "regex": "$sha256" }`) doesn't work reliably (e.g., because you don't publish separate `.sha256` files for your release assets), the manifest in the Scoop bucket might need manual hash updates via PRs by maintainers or contributors. Our current GitHub workflow updates the hashes in the manifest *in this repository*, which is good. For official buckets, they rely on `checkver` and `autoupdate`.

Good luck with publishing!
```
