#!/bin/bash

set -e

# Load the software and environment configuration
source "/opt/lsst/software/stack/loadLSST.bash"
if [[ -n $EUPS_TAG ]]; then
    setup -t "$EUPS_TAG" lsst_distrib
else
    setup lsst_distrib
fi

OUTPUT_COLLECTION="u/ocps/$JOB_ID"

# RUN_OPTIONS includes input collections and config overrides
pipetask run -p "$PIPELINE_URL" \
    -b "$BUTLER_REPO" \
    -o "$OUTPUT_COLLECTION" \
    $RUN_OPTIONS \
    --output-run "${OUTPUT_COLLECTION}/run" \
    -d "$DATA_QUERY"

# OUTPUT_GLOB matches dataset types that should be made into outputs
butler retrieve-artifacts \
    --collections "${OUTPUT_COLLECTION}/run" \
    --dataset-type "$OUTPUT_GLOB" \
    --transfer auto \
    --no-preserve-path \
    "$BUTLER_REPO" "$JOB_OUTPUT_DIR"
