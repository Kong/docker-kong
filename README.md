![Build Status](https://github.com/kong/docker-kong/actions/workflows/test.yml/badge.svg)

# About this Repo

This is the Git repo of the Docker
[official image](https://docs.docker.com/docker-hub/official_repos/) for
[kong](https://registry.hub.docker.com/_/kong/).
See [the Docker Hub page](https://registry.hub.docker.com/_/kong/)
for the full readme on how to use this Docker image and for information
regarding contributing and issues.

The full readme is generated over in [docker-library/docs](https://github.com/docker-library/docs),
specifically in [docker-library/docs/kong](https://github.com/docker-library/docs/tree/master/kong).

See a change merged here that doesn't show up on the Docker Hub yet?
Check [the "library/kong" manifest file in the docker-library/official-images
repo](https://github.com/docker-library/official-images/blob/master/library/kong),
especially [PRs with the "library/kong" label on that
repo](https://github.com/docker-library/official-images/labels/library%2Fkong). For more information about the official images process, see the [docker-library/official-images readme](https://github.com/docker-library/official-images/blob/master/README.md).

# For Kong developers

## Pushing a Kong patch release (x.y.Z) update

If the update does not require changes to the Dockerfiles other than
pointing to the latest Kong code, the process can be semi-automated as follows:

1. Check out this repository.

2. Run `./update.sh x.y.z`

   This will create a release branch, modify the relevant files automatically,
   give you a chance to review the changes and press "y", then
   it will push the branch and open a browser with the PR
   to this repository.

3. Peer review, run CI and merge the submitted PR.

4. Run `./submit.sh -p x.y.z`

   Once the internal PR is merged, this script will do the same
   for the [official-images](https://github.com/docker-library/official-images)
   repository. It will clone [Kong's fork](https://github.com/kong/official-images),
   create a branch, modify the relevant files automatically,
   give you a chance to review the changes and press "y", then
   it will push the branch and open a browser with the PR
   to the docker-library repository.

## Pushing a Kong minor release (x.Y.0) update

Not semi-automated yet. Note that minor releases are more likely to require more
extensive changes to the Dockerfiles.

