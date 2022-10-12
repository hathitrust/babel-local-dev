# Setting up babel-local-dev

> DRAFT DRAFT DRAFT

## Step 1: check out all the things

Clone all the repositories in a working directory.
We're going to be running docker from this working directory,
so `babel-local-dev` has access to the other repositories.

There's a lot, because we're replicating running on the 
dev servers with `debug_local=1` enabled.

```
$ mkdir workdir
$ cd workdir
$ git clone git@github.com:hathitrust/babel-local-dev.git
$ git clone git@github.com:hathitrust/catalog.git
$ git clone git@github.com:hathitrust/common.git
$ git clone git@github.com:hathitrust/imgsrv.git
$ git clone git@github.com:hathitrust/pt.git
$ git clone git@github.com:hathitrust/mdp-lib.git
$ git clone git@github.com:hathitrust/slip-lib.git
$ git clone git@github.com:hathitrust/plack-lib.git
$ git clone git@github.com:hathitrust/imgsrv-sample-data.git
# more to come
```

## Step 2: intialize all the submodules

*Insert fancy one liner if available.*

## Step 3: build the `babel-local-dev` environment

In your workdir:

```
docker-compose -f ./babel-local-dev/docker-compose.yml build
```

## Step 4: run `babel-local-dev`:

In your workdir:

```
docker-compose -f ./babel-local-dev/docker-compose.yml up
```

In your browser:

* http://localhost:8080/Search/Home
* http://localhost:8080/cgi/pt?id=test.pd_open

Huzzah!

## How this works (for now)

The `docker-commpose` provides a custom catalog configuration to the `nginx` service to 
proxy `babel` CGI requests to the `apache-cgi` service, and serve `common` requests from 
the local `common` checkout.

`apache-cgi` is there because `nginx` can only speak FastCGI/HTTP and running *all* the babel
apps under FastCGI/HTTP is still aspirational.

## TODO

- [ ] merge the `imgsrv` DEV-231-grok branch and update the `Dockerfile`s to include `grok`
- [ ] update `slip-lib/Searcher.pm` to set `wt=xml` because the new solr defaults return JSON
- [ ] adding `pt` requires filling out more of the `ht_web` tables (namely `mb_*`)
- [ ] easy mechanism to generate placeholder volumes in `imgsrv-sample-data` that correspond to the records in the catalog

