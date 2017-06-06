# kairosaero/circleci-build

A Docker container for use as a [CircleCI 2.0 Primary Container][1]

*NOTE TO KAIROS EMPLOYEES* - _this is a public repository and should contain no proprietary information or credentials._

Available on Docker Hub as `[kairosaero/circleci-build][2]`.

[1]: https://circleci.com/docs/2.0/custom-images/
[2]: https://hub.docker.com/r/kairosaero/dkr-circleci/

## Overview

This repository represents a _primary container_ for a CircleCI 2.0
containerized build.

### Docker Image Build

The image build does the following (turning the Dockerfile into a Docker image):

1. Packages up an Ubuntu 16.04 Xenial userspace (the same as the Kairos production environment)
2. Installs the production package loadout
3. Installs Packer and Docker, since they are not pure `apt` installs
4. Creates an empty Python 3.5 virtualenv and installs build prerequisites like
  `twine`, `setuptools`, and `credstash`
5. Creates a directory structure expected by some Kairos software
   (`/opt/kairos/*`)
6. Installs a suite of build scripts into `/opt/kairos/bin` to run standard
   build steps and puts them into `$PATH`.

### Docker Container Runtime

At container runtime, it expects the following environment variables to be defined:

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`
* `AWS_DEFAULT_REGION`

Optionally:

* `CREDSTASH_TABLE` - the credstash table to pull secrets from
  (default: _circleci-secrets_)
* `SECRET_SET_NAME` - the entry to pull from the credstash table
  (default: _default-build-secrets_)

Given those variables, it then:

1. Uses [credstash][3] to pull down JSON defining all environment variables
   containing secrets (see `build_secrets_template.json`)
2. Transforms the JSON with jq and injects the variable values into the
   environment
3. Uses those credentials to wire the virtualenv to a private PyPI server
4. Installs the Kairos build library from the private PyPI repo
5. Writes a default config file for publishing packages to a private PyPI
   server
6. Activates the virtualenv for all docker commands run in the container


[3]: https://github.com/fugue/credstash

# License

This source code is made available under the [MIT License](default-build-secrets).  See LICENSE for more information.

&#169; 2017 Kairos Aerospace.  All Rights Reserved.
