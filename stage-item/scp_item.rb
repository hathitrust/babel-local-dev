#!/usr/bin/env ruby

# Generate pairtree paths for items in the repository

require 'pairtree'

SDRROOT="/sdr1"
htid = ARGV[0]
raise "Usage: #{$0} namespace.id" unless htid
(namespace, objid) = htid.split(".",2)
pt_objid = Pairtree::Identifier.encode(objid)
pt_path = Pairtree::Path.id_to_path(objid)
pt_fullpath = File.join(SDRROOT,"obj",namespace,"pairtree_root",pt_path)
puts "scp $HT_SSH_HOST:'#{pt_fullpath}/#{pt_objid}.{zip,mets.xml}' ."
puts "bundle exec ruby stage_item.rb #{htid}"


