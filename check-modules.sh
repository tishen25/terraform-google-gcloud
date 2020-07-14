#!/bin/bash
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

if [ "$#" -lt 2 ]; then
    >&2 echo "Not all expected arguments set."
    exit 1
fi

GCLOUD_PATH=$1
PROPOSED_COMPONENTS_TO_INSTALL=$2

# get list of currently installed components
CURRENTLY_INSTALLED=$($GCLOUD_PATH components list --quiet --format json 2> /dev/null | jq -r '[.[] | select(.state.name!="Not Installed") | .id] | @tsv | gsub("\\t";",")')

# transform to arrays
IFS=',' read -r -a CURRENTLY_INSTALLED <<< "$CURRENTLY_INSTALLED"
IFS=',' read -r -a PROPOSED_COMPONENTS_TO_INSTALL <<< "$PROPOSED_COMPONENTS_TO_INSTALL"

#get diff btw components already installed and those that need to be installed
FINAL_COMPONENT_LIST=""
for component in "${PROPOSED_COMPONENTS_TO_INSTALL[@]}"
do
    if [[ ! ${CURRENTLY_INSTALLED[*]} =~ $component ]]; then
        FINAL_COMPONENT_LIST+="$component "
    fi
done

# if there is any component in list, install
if [[ $FINAL_COMPONENT_LIST ]]; then
    echo "Installing components $FINAL_COMPONENT_LIST";
    $GCLOUD_PATH components install "${FINAL_COMPONENT_LIST}" --quiet
else
    echo "All components already installed."
fi