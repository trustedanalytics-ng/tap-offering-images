#
# Copyright (c) 2017 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
FROM frodenas/postgresql:9.3
MAINTAINER Marcin Makowski <marcin.makowski@intel.com>

ADD scripts /scripts
COPY scripts/run.sh /scripts/run.sh
COPY scripts/first_run.sh /scripts/first_run.sh

RUN chmod +x /scripts/*.sh

ENTRYPOINT ["/scripts/run.sh"]
CMD [""]

EXPOSE 5432

# Expose our data directory
VOLUME ["/var/lib/postgresql"]
