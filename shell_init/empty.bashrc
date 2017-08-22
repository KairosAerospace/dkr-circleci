# This file is a no-op and is the default value of $BASH_ENV
# for the Docker build container
#
# CircleCI creates an initialization script that it sets as $BASH_ENV
# for the container when it's run.
#
# By having our container set it to the value of an empty script, we get a
# single, reliable path for configuring the container to always override
# the bash initialization behavior by appending to whatever the existing
# path is that's pointed to by $BASH_ENV.
#
# This file makes sure that the path always exists even when not overridden
export _KAIROS_EMPTY_INIT=1
