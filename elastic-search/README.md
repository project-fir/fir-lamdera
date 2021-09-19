### Elastic Search

This directory is for the deployment and management of ES on a GCP VM

#### Why?
Elastic Search Cloud is a bit of a letdown, including the GCP variant.

So, I'm going with a container running on a VM for the time being until I figure out what
features of ES I need.


#### Environments:
I don't want to bother with multiple envs but will need a place to experiment with schema changes, and need to be 
thoughtful about future environment isolation. Compromise:
 * introducing `-dev` suffix on all indexes, without `-dev` is our "production"
 * all scripts are configurable, but just with one configuration for now
