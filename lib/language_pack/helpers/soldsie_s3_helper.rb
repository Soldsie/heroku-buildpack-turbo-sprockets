require 'aws/s3'

module LanguagePack
  module Helpers
    class SoldsieS3Helper      

      S3_FILES = [
        {
          description: 'BigQuery p12 key',
          bucket: ENV['BIGQUERY_KEY_S3_BUCKET'],
          path: ENV['BIGQUERY_KEY_S3_PATH'],
          local_file: ENV['BIGQUERY_KEY']
        }
      ]

      def initialize
        AWS::S3::Base.establish_connection!(
          access_key_id: ENV['AWS_ACCESS_KEY_ID'], 
          secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
        )
      end

      def download
        S3_FILES.each do |s3_file_conf|
          puts "Downloading S3 file for #{s3_file_conf[:description]} ..."

          last_dot_index = s3_file_conf[:path].rindex('.')                    
          s3_object_prefix = s3_file_conf[:path][0..last_dot_index - 1]
          bucket = AWS::S3::Bucket.find(s3_file_conf[:bucket], {prefix: s3_object_prefix})
          if !bucket
            puts "Failed to find S3 bucket #{s3_file_conf[:bucket]}, S3 download of #{s3_file_conf[:description]} skipped ..."
          else
            s3_objects = bucket.objects(s3_file_conf[:path])
            if !s3_objects || s3_objects.empty?
              puts "Failed to find file #{s3_file_conf[:path]}, S3 download of #{s3_file_conf[:description]} skipped ..."
            else
              s3_obj = s3_objects.detect {|o| o.key.to_s.rindex(s3_file_conf[:path])}
              # OK, found the file we are looking for, download it!              
              open(s3_file_conf[:local_file], 'w+') do |file|
                AWS::S3::S3Object.stream(s3_obj.key, s3_obj.bucket.name) do |chunk|
                  file.write(chunk)
                end                
              end
            end
          end          

          puts 'Done!'
        end        
      end
    end
  end
end
