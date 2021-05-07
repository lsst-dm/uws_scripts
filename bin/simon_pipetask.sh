#!/bin/bash

set -e

# Load the software and environment configuration
source "/opt/lsst/software/stack/loadLSST.bash"
if [[ -n $EUPS_TAG ]]; then
    setup -t "$EUPS_TAG" lsst_distrib
else
    setup lsst_distrib
fi
eups list lsst_distrib

python bin/put_many_positions.py $BUTLER_REPO $VISIT $DETECTOR $INSTRUMENT $PUT_COLLECTION --ra $CUTOUT_RA --dec $CUTOUT_DEC --size $CUTOUT_SIZE

# RUN_OPTIONS includes input collections and config overrides
pipetask run -t "$PIPELINE_TASK_CLASS" \
    -b "$BUTLER_REPO" \
    -o "$OUTPUT_COLLECTION" \
    --register-dataset-types \
    $RUN_OPTIONS \
    --output-run "${OUTPUT_COLLECTION}/run" \
    -d "$DATA_QUERY"

# OUTPUT_GLOB matches dataset types that should be made into outputs
butler retrieve-artifacts --collections $OUTPUT_COLLECTION/run --dataset-type "$OUTPUT_GLOB" $BUTLER_REPO $JOB_OUTPUT_DIR
