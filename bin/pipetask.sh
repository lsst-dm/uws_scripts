#!/bin/bash

# Environment variables:
#   JOB_OUTPUT_DIR
#     Set by UWS server; directory where output files should be placed
#   EUPS_TAG
#     Optional; eups tag to setup
#   JOB_ID
#     Set by UWS server; unique identifier for the job
#   PIPELINE_URL
#     File path or URL to pipeline YAML file
#     May include $ENV_VAR to be expanded using eups environment
#     May include #fragment[,fragment] to select subsets of the pipeline
#   BUTLER_REPO
#     File path or URL to Butler root or config file
#   RUN_OPTIONS
#     Any other pipetask options
#     Should include -i {input collection list}
#     May include -c or -C config overrides
#     TODO: separate this into non-generic arguments
#   DATA_QUERY
#     Butler data query selecting datasets to be processed
#   OUTPUT_GLOB
#     Pattern matching dataset types that should be made into outputs
#   DEBUG_PIPETASK_SH
#     Optional; log loadLSST and setup lsst_distrib script executions

exec > "$JOB_OUTPUT_DIR"/ocps.log 2>&1

# Exit on command failure
set -e
# Conditionally enable debug logging
[ -n "$DEBUG_PIPETASK_SH" ] && set -x

# Load the software and environment configuration
# Ignore external file
# shellcheck disable=SC1091
source "/opt/lsst/software/stack/loadLSST.bash"

if [[ -n "$EUPS_TAG" ]]; then
    setup -t "$EUPS_TAG" lsst_distrib
else
    setup lsst_distrib
fi

# Always log these commands
set -x

OUTPUT_COLLECTION="u/ocps/$JOB_ID"

# Ignore unquoted RUN_OPTIONS used to provide multiple command arguments
# shellcheck disable=SC2086
pipetask run -p "$PIPELINE_URL" \
    -b "$BUTLER_REPO" \
    -o "$OUTPUT_COLLECTION" \
    $RUN_OPTIONS \
    --output-run "${OUTPUT_COLLECTION}/run" \
    -d "$DATA_QUERY"

butler retrieve-artifacts \
    --collections "${OUTPUT_COLLECTION}/run" \
    --dataset-type "$OUTPUT_GLOB" \
    --transfer auto \
    --no-preserve-path \
    "$BUTLER_REPO" "$JOB_OUTPUT_DIR"
