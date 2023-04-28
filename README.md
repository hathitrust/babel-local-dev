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
* `http://localhost:8080/cgi/mb`
* `http://localhost:8080/cgi/ls`
* `http://localhost:8080/cgi/whoami`
* `http://localhost:8080/cgi/ping`
* etc

## How this works (for now)

* catalog runs nginx + php
* babel cgi apps run under apache in a single container
* imgsrv plack/psgi process runs in its own container

## Staging an Item

First, get a HathiTrust ZIP and METS. The easiest way to do this is probably by
using the [Data API client](https://babel.hathitrust.org/cgi/htdc) to download
a public domain item unencumbered by any contractual restrictions, for example
`uc2.ark:/13960/t4mk66f1d`. Select "Download" and in turn select "Item METS
file" and "entire item" and submit the form; this will download the ZIP and
METS respectively.

Running the stage item script requires a Ruby runtime. It will automate putting
the item in the appropriate location under `imgsrv-sample-data`, fetch the
bibliographic data, and extract and index the full text.

`setup.sh` will attempt to install the Ruby library dependencies for `stage-item`.
After it finishes, make sure all the solr and database services are running:

```bash
docker-compose build
docker-compose up
```

Then, run `stage-item` with the downloaded zip and METS:

```bash
cd stage-item
bundle exec ruby stage_item.rb uc2.ark:/13960/t4mk66f1d ark+=13960=t4mk66f1d.zip ark+=13960=t4mk66f1d.mets.xml
```

Note that the zip and METS must be named as they are in the actual
repository -- if you name them "foo.zip" or "foo.xml" they will not be renamed,
and full-text indexing and PageTurner will not be able to find the item.

## Fetching an Item

To batch download public domain items using the Data API:

* copy `stage_item/.htd.ini.example` to `stage_item/.htd.ini`
* request a [Data API Key](https://babel.hathitrust.org/cgi/kgs)
* update `.htd.ini` with the access and secret keys

You can then fetch an item with

```bash
# you've already done the stage-item configuration
cd stage_item

# pass htids as arguments; the --stage option will generate a bash script 
# that will stage the downloaded items
bundle exec ruby fetch_item.rb --stage /tmp/run.sh loc.ark:/13960/t05x2fk69 loc.ark:/13960/t05x2js29
sh /tmp/run.sh

# if you have a filenaming containing a list of identifiers:
bundle exec ruby fetch_item.rb --stage /tmp/run.sh --input /tmp/htid-list.txt
sh /tmp/run.sh
```

## Resetting / updating database & solr schema

If you need to reset or update the database or solr schema, you will need to
make sure the persistent volumes for them are removed so that when you restart
the containers they will get a fresh copy of the schema.

```bash
docker-compose down -v
```

## TODO

- [ ] link to documentation for important tasks - e.g. running apps under debugging, updating css/js, etc
- [ ] easy mechanism to generate placeholder volumes in `imgsrv-sample-data` that correspond to the records in the catalog
- [ ] make it easier to fetch real volumes
