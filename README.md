# Setting up babel-local-dev

> DRAFT DRAFT DRAFT

## Step 1: check out all the things

Clone all the repositories in a working directory.
We're going to be running docker from this working directory,
so `babel-local-dev` has access to the other repositories.

First clone this repository:
```bash
git clone git@github.com:hathitrust/babel-local-dev.git babel
```

Then run:

```bash
cd babel
./setup.sh
```

This will check out the other repositories along with their submodules.
There's a lot, because we're replicating running on the dev servers with
`debug_local=1` enabled.

## Step 3: build the `babel-local-dev` environment

In your workdir:

```
docker-compose build
```

## Step 4: run `babel-local-dev`:

In your workdir:

```
docker-compose up
```

In your browser:

* catalog: `http://localhost:8080/Search/Home`
* catalog solr: `http://localhost:9033`
* full-text solr: `http://localhost:8983`

PageTurner & imgsrv:

* `http://localhost:8080/cgi/pt?id=test.pd_open`
* `http://localhost:8080/cgi/imgsrv/cover?id=test.pd_open`
* `http://localhost:8080/cgi/imgsrv/image?id=test.pd_open&seq=1`
* `http://localhost:8080/cgi/imgsrv/html?id=test.pd_open&seq=1`
* `http://localhost:8080/cgi/imgsrv/download/pdf?id=test.pd_open&seq=1&attachment=0`

mysql is exposed at 127.0.0.1:3307. The default username & password with write
access is `mdp-admin` / `mdp-admin` (needless to say, do not use this image in
production!)

```bash
mysql -h 127.0.0.1 -p 3307 -u mdp-admin -p
```
Huzzah!

Not yet configured:
* `http://localhost:8080/cgi/whoami`
* `http://localhost:8080/cgi/ping`
* etc

## How this works (for now)

* catalog runs + php
* babel cgi apps run under apache in a single container
* imgsrv plack/psgi process runs in its own container
* apache proxies to imgsrv & catalog

## Rebuilding Assets

To rebuild the CSS and JavaScript for `firebird-common` and `pt`:

```bash
 build firebird-common
docker-compose run node /htapps/babel/firebird-common/bin/build.sh

# build pt/firebird
docker-compose run node /htapps/babel/pt/bin/build.sh
```

## Staging an Item

The easiest way to do this (for internal developers) is to copy a ZIP and METS
from production:

```bash
./scp_and_stage_item.sh uc2.ark:/13960/t4mk66f1d ...
```

## Fetching an Item

> **Warning**
> As of August 2023 this is not working reliably.

To batch download public domain items using the Data API:

* copy `stage_item/.htd.ini.example` to `stage_item/.htd.ini`
* request a [Data API Key](https://babel.hathitrust.org/cgi/kgs)
* update `.htd.ini` with the access and secret keys

You can then fetch one or more items with

```bash
./fetch_and_stage_item.sh loc.ark:/13960/t05x2fk69 loc.ark:/13960/t05x2js29
```

## Database Utilities 

### Resetting / updating database & solr schema

`reset_database.sh`: If you need to reset or update the database or solr
schema, you will need to make sure the persistent volumes for them are removed
so that when you restart the containers they will get a fresh copy of the
schema. The `reset_database.sh` script will do this.


`mysql_sdr.sh`: This will connect to the `ht` database running inside the mysql
container.

## Authentication

You can simulate various authenticated scenarios by setting environment
variables in Apache. There is appropriate setup for a variety of scenarios and
user types in configuration files under `apache-cgi/auth`, and a helper script
`switch_auth.sh` to allow you to pick a particular scenario and configure the
local Apache server to use it.

## TODO

- [ ] link to documentation for important tasks - e.g. running apps under debugging, updating css/js, etc
- [ ] easy mechanism to generate placeholder volumes in `imgsrv-sample-data` that correspond to the records in the catalog
