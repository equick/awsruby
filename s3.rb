#!/usr/bin/env ruby

#------------------------------------------------------------#
#                                                            #
#  Sample S3 script using AWS SDK for Ruby V2                #
#                                                            #
#------------------------------------------------------------#

require 'rubygems'
require 'aws-sdk'
require 'optparse'

$prog = $PROGRAM_NAME

def usage
  puts "Usage: #{$prog} --bucket_name=<BUCKET_NAME> --region=<REGION> --create"
  puts "#{$prog} --bucket_name=<BUCKET_NAME> --region=<REGION> --delete"
  puts "#{$prog} --bucket_name=<BUCKET_NAME> --region=<REGION> --list"
  puts "#{$prog} --bucket_name=<BUCKET_NAME> --region=<REGION> --exists"
  puts "#{$prog} --bucket_name=<BUCKET_NAME> --region=<REGION> --file_name=<FILE_NAME> --upload"
  exit 1
end

region = 'eu-west-1'
bucket_name = nil
file_name = nil
action = nil
actions = Array['create', 'delete', 'list', 'exists', 'upload']

begin
  OptionParser.new do |opt|
    opt.on('--bucket_name BUCKETNAME') { |o| bucket_name = o }
    opt.on('--file_name FILENAME') { |o| file_name = o }
    opt.on('--region REGION') { |o| region = o }
    opt.on('--create') { action = 'create' }
    opt.on('--delete') { action = 'delete' }
    opt.on('--list')   { action = 'list' }
    opt.on('--exists') { action = 'exists' }
    opt.on('--upload') { action = 'upload' }
  end.parse!
rescue OptionParser::InvalidOption
  puts 'Warning: Invalid option'
end

usage if bucket_name.nil? || !(actions.include?(action)) || actions.empty?

client = Aws::S3::Client.new(region: region)

case action
when 'create'
  begin
    resp = client.create_bucket(bucket: bucket_name)
    puts resp.data.location
  rescue => exception
    puts exception
  end
when 'list'
  begin
    resp = client.list_objects(bucket: bucket_name)
    resp.each do |item|
      item.contents.each do |file|
        puts "name = #{file.key}"
        puts "size = #{file.size}"
        puts "last_modified = #{file.last_modified}"
        puts ''
      end
    end
  rescue => exception
    puts exception
  end
when 'upload'
  begin
    obj = Aws::S3::Object.new(bucket_name: bucket_name, key: file_name, client: client)
    resp = obj.upload_file(file_name)
    puts resp
  rescue => exception
    puts exception
  end
when 'exists'
  bucket = Aws::S3::Bucket.new(name: bucket_name, region: region)
  resp = bucket.exists?
  puts resp
when 'delete'
  begin
    bucket = Aws::S3::Bucket.new(name: bucket_name, region: region)
    bucket.delete!
  rescue => exception
    puts exception
  end
else
  usage
end
