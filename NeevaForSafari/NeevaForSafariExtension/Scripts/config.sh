#!/bin/sh

#
# Copyright 2022 Neeva Inc. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#  

echo "Building API Config for NeevaForSafari"

# Install Node.js dependencies and build user scripts
yarn install
yarn build
