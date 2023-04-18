#!/usr/bin/env ruby

require 'oauth'
require 'inifile'
require 'pp'
require "optparse"

config_filename = File.join(__dir__, '.htd.ini')
begin
  config = IniFile.load(File.realpath(config_filename))
rescue Errno::ENOENT
  STDERR.puts "⛔ #{config_filename} not found"
  exit
end

options = {}

option_parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} [options] identifer identifier..."

  opts.on("--input FILENAME", "Specifies the input filename.") do |v|
    options[:input_filename] = v
  end

  opts.on("--stage FILENAME", "Specifies the stage filename.") do |v|
    options[:stage_filename] = v
  end
end

option_parser.parse!
identifiers = []
if options[:input_filename]
  File.readlines(options[:input_filename]).each do |line|
    identifiers << line.chomp
  end
else
  identifiers = ARGV.dup
end

if identifiers.empty?
  STDERR.puts option_parser.banner
  exit
end

consumer = OAuth::Consumer.new(
  config['htd']['access_key'], 
  config['htd']['secret_key'], 
  site: 'https://babel.hathitrust.org/cgi/htd'
)
access_token = OAuth::AccessToken.new(consumer)

processed = []
identifiers.each do |identifier|
  response = consumer.request(:get, "/structure/#{identifier}?v=2", access_token, { scheme: :query_string} )
  unless response.kind_of? Net::HTTPSuccess
    puts "⛔ /structure/#{identifier} received #{response.code}; skipping!"
    next
  end
  mets_filename = response.to_hash['content-disposition'].first.gsub('filename=', '')

  File.open(mets_filename, 'w') do |f|
    f.write(response.body)
  end

  response = consumer.request(:get, "/aggregate/#{identifier}?v=2", access_token, { scheme: :query_string} )
  unless response.kind_of? Net::HTTPSuccess
    puts "⛔ /aggregate/#{identifier} received #{response.code}; skipping!"
    File.unlink(mets_filename)
    next
  end
  zip_filename = response.to_hash['content-disposition'].first.gsub('filename=', '')

  File.open(zip_filename, 'wb') do |f|
    f.write(response.body)
  end

  puts "🤐 Downloaded #{identifier} ➜ #{zip_filename} + #{mets_filename}"

  processed << [ identifier, zip_filename, mets_filename ]
end

unless options[:stage_filename].nil?
  File.open(options[:stage_filename], 'w') do |f|
    processed.each do |identifier, zip_filename, mets_filename|
      f.puts %{bundle exec ruby ./stage_item.rb "#{identifier}" "#{zip_filename}" "#{mets_filename}"}
    end
  end
end


