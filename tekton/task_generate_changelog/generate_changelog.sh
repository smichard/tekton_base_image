apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: generate-changelog
  labels:
    app.kubernetes.io/version: "0.1"
  annotations:
    tekton.dev/pipelines.minVersion: "0.12.1"
    tekton.dev/categories: Build Tools
    tekton.dev/tags: build-tool
    tekton.dev/platforms: "linux/amd64"
spec:
  description: >-
    Task to generate a build tag
  workspaces:
    - name: source
  results:
  - name: changelog-file-path
    description: file path of the changelog file
  params:
  - name: changelog-file-name
    type: string
    description: file name of the changelog file
    default: "CHANGELOG.md"
  - name: repo-url
    type: string
    description: "Url of the git repo for the code of deployment"
  steps:
    - name: generate-changelog
      image: quay.io/michard/tekton_base_image:0.1.10
      script: |
        #!/bin/sh
        # Exit on error
        set -e

        # Error handling
        trap 'echo "An error occurred at line $LINENO. Exiting."' ERR

        # Path to the Git repository (current directory)
        REPO_DIR="/workspace/source"
        CHANGELOG_FILE="$REPO_DIR/$(params.changelog-file-name)"
        GITHUB_REPO_URL=$(params.repo-url) # Replace with your repository URL

        # save changelog file path to results variable
        echo ${CHANGELOG_FILE} | tr -d "\n" | tee $(results.changelog-file-path.path)

        echo "Starting changelog generation script..."
        git config --global --add safe.directory /workspace/source

        # Go to the repository directory
        cd $REPO_DIR

        # Fetch the latest changes
        git fetch --tags
        echo "Fetched latest tags."

        # Get the latest tag
        LATEST_TAG=$(git describe --tags --abbrev=0)

        # Collect and list unreleased changes
        UNRELEASED_COMMITS=$(git log $LATEST_TAG..HEAD --oneline)
        if [ ! -z "$UNRELEASED_COMMITS" ]; then
            echo "## Unreleased Changes" >> $CHANGELOG_FILE
            echo "" >> $CHANGELOG_FILE
            echo "Processing unreleased changes..."
            echo "$UNRELEASED_COMMITS" | while read -r COMMIT; do
                HASH=$(echo $COMMIT | awk '{print $1}')
                MESSAGE=$(echo $COMMIT | sed -E 's/^[^:]+(\([^)]+\))?: //')
                echo "- $MESSAGE [\`$HASH\`]($GITHUB_REPO_URL/commit/$HASH)" >> $CHANGELOG_FILE
            done
            echo "" >> $CHANGELOG_FILE
        fi

        # Get tags in reverse order
        TAGS=$(git tag --sort=-v:refname)

        # Check if there are any tags
        if [ -z "$TAGS" ]; then
            echo "No tags found in the repository."
            exit 1
        fi

        echo "Found tags: $TAGS"

        # Placeholder for the previous tag
        PREV_TAG=HEAD

        # Create or clear the changelog file
        echo "" > $CHANGELOG_FILE

        # Add the introductory text to the changelog
        echo "# Changelog" >> $CHANGELOG_FILE
        echo "" >> $CHANGELOG_FILE
        echo "All notable changes to this project will be documented in this file." >> $CHANGELOG_FILE
        echo "" >> $CHANGELOG_FILE
        echo "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) and to [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)." >> $CHANGELOG_FILE
        echo "" >> $CHANGELOG_FILE

        # Define categories
        CATEGORIES="feat fix ci perf docs gitops deploy test demo build chore style refactor"

        # Regular expression for matching conventional commits
        CONVENTIONAL_COMMIT_REGEX="^.* (feat|fix|ci|perf|docs|gitops|deploy|test|demo|build|chore|style|refactor)(\(.*\))?: "

        # Iterate over tags
        for TAG in $TAGS; do
            echo "Processing tag: $TAG"
            TAG_DATE=$(git log -1 --format=%ai $TAG | cut -d ' ' -f 1)
            echo "## $TAG ($TAG_DATE)" >> $CHANGELOG_FILE
            echo "" >> $CHANGELOG_FILE

            # Collect all commits for this tag range
            ALL_COMMITS=$(git log $TAG..$PREV_TAG --oneline)

            # Process each category
            for KEY in $CATEGORIES; do
                CATEGORY_COMMITS=$(echo "$ALL_COMMITS" | grep -E "^.* $KEY(\(.*\))?: " || true)
                if [ ! -z "$CATEGORY_COMMITS" ]; then
                    case $KEY in
                        "feat") CATEGORY_NAME="Feature" ;;
                        "fix") CATEGORY_NAME="Bug Fixes" ;;
                        "ci") CATEGORY_NAME="Continuous Integration" ;;
                        "perf") CATEGORY_NAME="Performance Improvements" ;;
                        "docs") CATEGORY_NAME="Documentation" ;;
                        "gitops") CATEGORY_NAME="GitOps" ;;
                        "deploy") CATEGORY_NAME="Deployment" ;;
                        "test") CATEGORY_NAME="Test" ;;
                        "demo") CATEGORY_NAME="Demo" ;;
                        "build") CATEGORY_NAME="Build" ;;
                        "chore") CATEGORY_NAME="Chore" ;;
                        "style") CATEGORY_NAME="Style" ;;
                        "refactor") CATEGORY_NAME="Refactor" ;;
                    esac
                    echo "### $CATEGORY_NAME" >> $CHANGELOG_FILE
                    echo "Listing commits for category: $CATEGORY_NAME under tag $TAG"
                    echo "$CATEGORY_COMMITS" | while read -r COMMIT; do
                        HASH=$(echo $COMMIT | awk '{print $1}')
                        MESSAGE=$(echo $COMMIT | sed -E "s/^$HASH $KEY(\(.*\))?: //")
                        echo "- $MESSAGE [\`$HASH\`]($GITHUB_REPO_URL/commit/$HASH)" >> $CHANGELOG_FILE
                    done
                    echo "" >> $CHANGELOG_FILE
                fi
            done

            # Process 'Other' category
            OTHER_COMMITS=$(echo "$ALL_COMMITS" | grep -v -E "$CONVENTIONAL_COMMIT_REGEX" || true)
            if [ ! -z "$OTHER_COMMITS" ]; then
                echo "### Other" >> $CHANGELOG_FILE
                echo "Listing commits for category: Other under tag $TAG"
                echo "$OTHER_COMMITS" | while read -r COMMIT; do
                    HASH=$(echo $COMMIT | awk '{print $1}')
                    MESSAGE=$(echo $COMMIT | sed -E 's/^[^ ]* //')
                    echo "- $MESSAGE [\`$HASH\`]($GITHUB_REPO_URL/commit/$HASH)" >> $CHANGELOG_FILE
                done
                echo "" >> $CHANGELOG_FILE
            fi

            echo "Completed processing tag: $TAG"
            # Update the previous tag
            PREV_TAG=$TAG
        done

        echo "Changelog generation complete."

        echo "Content of the Changelog file:"
        cat CHANGELOG.md