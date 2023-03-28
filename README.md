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
docker-compose -f ./babel-local-dev/docker-compose.yml build
```

## Step 4: run `babel-local-dev`:

In your workdir:

```
docker-compose -f ./babel-local-dev/docker-compose.yml up
```

In your browser:

* catalog: `http://localhost:8080/Search/Home`
* catalog solr: `http://localhost:9033`
* full-text solr: `http://localhost:8983`

imgsrv:

* `http://localhost:8888/cgi/imgsrv/cover?id=test.pd_open`
* `http://localhost:8888/cgi/imgsrv/image?id=test.pd_open&seq=1`
* `http://localhost:8888/cgi/imgsrv/html?id=test.pd_open&seq=1`
* `http://localhost:8888/cgi/imgsrv/download/pdf?id=test.pd_open&seq=1&attachment=0`

mysql is exposed at 127.0.0.1:3307. The default username & password with write
access is `mdp-admin` / `mdp-admin` (needless to say, do not use this image in
production!)

```bash
mysql -h 127.0.0.1 -p 3307 -u mdp-admin -p
```
Huzzah!

Not yet configured:
* `http://localhost:8888/cgi/pt?id=test.pd_open`
* `http://localhost:8888/cgi/mb`
* `http://localhost:8888/cgi/whoami`
* `http://localhost:8888/cgi/ping`

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

First make sure all the dependencies are running:

```bash
docker-compose build
docker-compose up
```

Then, install dependencies for the `stage-item` script and run it with the
downloaded zip and METS:

```bash
cd babel-local-dev/stage-item
bundle config set --local path 'vendor/bundle'
bundle install
bundle exec ruby stage_item.rb uc2.ark:/13960/t4mk66f1d ark+=13960=t4mk66f1d.zip ark+=13960=t4mk66f1d.mets.xml
```

## TODO

- [ ] adding `pt` requires filling out more of the `ht_web` tables (namely `mb_*`)
- [ ] easy mechanism to generate placeholder volumes in `imgsrv-sample-data` that correspond to the records in the catalog
