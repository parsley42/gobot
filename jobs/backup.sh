#!/bin/bash

# backup.sh - back up job for backing up the robot's state (brain)

source $GOPHER_INSTALLDIR/lib/gopherbot_v1.sh

if [ "$PTYPE" == "plugCommand" -o "$PTYPE" == "jobCommand" ]
then
    Say "Starting backup requested by user $GOPHER_USER in channel: $GOPHER_START_CHANNEL"
fi

PTYPE=$GOPHER_PIPELINE_TYPE
CHANGES=$(cd $STATE_DIR; git status --porcelain)
echo "Changes: $CHANGES" >&2
if [ -z "$CHANGES" ] # no changes
then
    if [ "$PTYPE" == "plugCommand" -o "$PTYPE" == "jobCommand" ]
    then
        Say "No changes, exiting..."
        exit 0
    fi
fi

GIT_URL=$(cd $STATE_DIR; git remote get-url origin)

SetWorkingDirectory "$STATE_DIR"
AddTask git-credentials "$GIT_URL"
AddTask pause-brain
AddTask exec git add --all
AddTask resume-brain
AddTask exec git commit -m "Backup of robot state"
AddTask exec git push
if [ "$PTYPE" == "plugCommand" -o "$PTYPE" == "jobCommand" ]
then
    AddTask say "Backup complete"
fi
