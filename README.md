# Alpheios Puppet Repository

The Alpheios Puppet Repository contains a suite of [Puppet 4](https://puppet.com/) manifests that configure the Alpheios AWS EC2 instances that run the various Alpheios back-end web services.

Most deployments are handled fully by the puppet papply script, which is run via cronjob.  Code is deployed from GitHub, and papply will pick up updates from the GitHub repos when it runs.

However, there are a few exceptions that require manual steps.

## Lexicon Services

The eXist based lexicon services (for Alpheios Full Definitions) are packaged in Docker containers built from the https://github.com/alpheios-project/lex-docker repository. This Dockerfile in turn pulls from the individual GitHub repositories for the various lexicons (e.g. https://github.com/alpheios-project/lsj etc.).  So, pappy will pickup changes to the Dockerfile repo, but unless the Dockerfile changes to pull a different tag of a lexicon release (and right now we don't use tagged releases of the lexicons), it won't pickup fixes to the lexicon xml.

So, if you change the xml of a lexicon file, you need to force a rebuild the Docker image.  The simplest way to do this is to ssh into all of the EC2 instances which are deployed as the `repos` host, and run the following commands

```
sudo su - 
cd /docker/build/exist
docker build -t lexsvc . --no-cache
docker stop lexsvc
```

(docker is configured by puppet to have lexsvc running constantly, so it will restart it from the new image as soon as it is stopped)

You may also want to clear the varnish caches that sit in front of the lexicon service to make sure the changes are picked up immediately.

The simplest way to do this is to ssh into all of the EC2 instances which are deployed as the `varnishlex` host and run the following commands

```
sudo su - 
docker stop varnishlex
papply
```

(for some reason, on the varnish instances the docker container doesn't get restarted automatically. Running `papply` will restart it).

