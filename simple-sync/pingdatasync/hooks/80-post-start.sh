#!/usr/bin/env sh
${VERBOSE} && set -x

# shellcheck source=/dev/null
test -f "${BASE}/lib.sh" && . "${BASE}/lib.sh"
while true ; do
    curl -ss -o /dev/null -k https://pingdirectory/directory/v1 2>&1 && break
    sleep_at_most 8
done
sleep 2

#
# Set the sync pipe at the beginning of the changelog
#
realtime-sync set-startpoint \
    --end-of-changelog \
    --pipe-name pingdirectory_source-to-pingdirectory_destination

#
# Enable the sync pipe
#
dsconfig set-sync-pipe-prop \
    --pipe-name pingdirectory_source-to-pingdirectory_destination  \
    --set started:true \
    --no-prompt