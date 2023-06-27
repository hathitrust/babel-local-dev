#!ruby

require "faraday"
require "faraday/follow_redirects"
require "fileutils"
require "ht/pairtree"
require "marc"
require "sequel"
require "tempfile"

# The parent of babel-local-dev where all the HathiTrust repos are checked out
HTDEV_ROOT = ENV["HTDEV_ROOT"] || File.realpath(File.join(__dir__,".."))

METADATA_ROOT = ENV["METADATA_ROOT"] || File.join(HTDEV_ROOT,"sample-data","metadata")
SDRDATAROOT = ENV["SDRDATAROOT"] || File.join(HTDEV_ROOT,"sample-data","sdr1")
CATALOG_BASE = ENV["CATALOG_BASE"] || "https://catalog.hathitrust.org"
MYSQL_URL = ENV["MYSQL_URL"] || "mysql2://mdp-admin:mdp-admin@127.0.0.1:3307/ht"
CATALOG_SOLR = ENV["CATALOG_SOLR"] || "http://localhost:9033/solr/catalog"
LSS_SOLR = ENV["LSS_SOLR"] || "http://localhost:8983/solr/core-x"

class StageItem
  attr_reader :htid, :namespace, :objid, :pt_objid, :zip, :mets, :pt

  def self.main
    usage unless ARGV.length >= 1

    StageItem.new(*ARGV).run 
  end

  def initialize(htid, zip=nil, mets=nil)
    @htid = htid
    (@namespace, @objid) = htid.split(".",2)
    @pt_objid = Pairtree::Identifier.encode(@objid)
    @zip = zip || "#{pt_objid}.zip"
    @mets = mets || "#{pt_objid}.mets.xml"

    self.class.usage unless @zip.match?(/\.zip$/) && @mets.match?(/\.xml$/)

    self.class.usage("Can't find #{@zip}") unless File.exist?(@zip)
    self.class.usage("Can't find #{@mets}") unless File.exist?(@mets)

    @pt = HathiTrust::Pairtree.new(root: File.join(SDRDATAROOT,'obj'))
  end

  def run
    stage_content
    stage_metadata
    index_full_text
  end

  def stage_metadata
    Tempfile.create(["metadata", ".json"], File.realpath(METADATA_ROOT)) do |f|
      metadata = fetch_metadata(f)
      populate_database(metadata)
      index_metadata(File.basename(f.path))
    end
  end

  def stage_content
    pt.create(htid, new_namespace_allowed: true)
    repo_path = pt.path_for(htid)

    puts("↪️ Copying zip and mets to repo #{repo_path}\n")
    FileUtils.cp(zip,File.join(repo_path,"#{pt_objid}.zip"))
    FileUtils.cp(mets,File.join(repo_path,"#{pt_objid}.mets.xml"))
  end

  def fetch_metadata(tempfile)
    url = "/Record/HTID/#{htid}.json"
    puts "📙 Getting metadata #{CATALOG_BASE}#{url} and saving to tempfile #{tempfile.path}\n"

    conn = Faraday.new(CATALOG_BASE) do |f|
      f.response :follow_redirects
    end

    json = conn.get("/Record/HTID/#{htid}.json").body

    tempfile.write(json)
    tempfile.flush

    MARC::Record.new_from_hash(JSON.parse(json))
  end

  def populate_database(record)
    catalog_id = record["001"].value

    # each item has a 974 field; the HTID is in 974$u
    item_data = record.fields("974").find { |f| f["u"] == htid }
    raise "Can't find item data for #{htid} in record #{catalog_id}" unless item_data

    rights_attr = item_data["r"]
    rights_reason = item_data["q"]
    rights_source = item_data["s"]
    zephir_update_date = item_data["d"]

    # Simplification for the purposes of testing data: for now, the access
    # profile is 2 ('google') if the item was digitized by google and 1
    # ('open') otherwise. We can add options later to override all the rights
    # stuff for purposes of testing.
    access_profile = (rights_source == 'google') ? 2 : 1

    dbh = Sequel.connect(MYSQL_URL)

    sql = <<~SQL
      REPLACE INTO rights_current (namespace, id, attr, reason, source, access_profile, user, note) VALUES
       (?, ?,
          (SELECT id FROM attributes WHERE name = ?),
          (SELECT id FROM reasons WHERE name = ?),
          (SELECT id FROM sources WHERE name = ?),
          ?,'stage-item','staged from catalog record by stage_item.rb')
    SQL

    values = [namespace, objid, rights_attr, rights_reason, rights_source, access_profile]
    dbh[sql,*values].insert

    sql = <<~SQL
      REPLACE INTO slip_rights (nid, attr, reason, source, user, time, sysid, update_time) 
        SELECT concat(namespace, '.', id), attr, reason, source, user, time, ?, ? FROM rights_current WHERE namespace = ? and id = ?
    SQL

    values = [catalog_id, zephir_update_date, namespace, objid]
    dbh[sql,*values].insert
  end

  def index_metadata(file)
    puts "📕 Indexing metadata..."

    catalog_utils_sh  = File.join(HTDEV_ROOT,"hathitrust_catalog_indexer","bin","utils.sh")
    system("docker compose run --rm traject bin/cictl index file metadata/#{file}")
    system("docker compose run --rm traject bin/cictl solr commit")
  end

  def index_full_text
    puts "📖 Indexing full text..."

    system("docker compose run --rm slip index/docs-j -r11 -I#{htid}")

    slip_sample_dir = File.join(HTDEV_ROOT,"slip","sample")
    load_into_solr_sh = File.join(HTDEV_ROOT,"slip","sample","load_into_solr.sh")
    pt_objid = File.basename(mets,".mets.xml")

    system("bash #{slip_sample_dir}/load_into_solr.sh #{slip_sample_dir}/#{pt_objid}*.solr.xml")
  end

  def self.usage(err="")
    STDERR.puts(err)
    STDERR.puts <<~EOT
      Usage: $0 namespace.barcode [some_item.zip some_item.mets.xml]

      Stages an item into the sample repository from a given zip and XML file.
      If the ZIP and METS filenames are not provided, they will be generated from the given HathiTrust item ID.
      
      It:
        * fetches metadata from the catalog
        * indexes this into the sample catalog
        * populates the rights_current and slip_rights table
        * indexes the full text
    EOT

    exit 1
  end
end

if $0 == __FILE__
  StageItem.main
end
