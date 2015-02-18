#!/app/bin/ruby

# first install the gem
`gem install aws-s3:0.6.3`

require 'rubygems'
require 'aws/s3'

def download(aws_key, aws_secret, s3_bucket, s3_path, local_file)
  if !File.exists?(local_file)
    AWS::S3::Base.establish_connection!(
      access_key_id: aws_key,
      secret_access_key: aws_secret
    )

    last_dot_index = s3_path.rindex('.')                    
    s3_object_prefix = s3_path[0..last_dot_index - 1]
    bucket = AWS::S3::Bucket.find(s3_bucket, {prefix: s3_object_prefix})
    if !bucket
      puts "Failed to find S3 bucket #{bucket}"
      exit(false)
    else
      s3_objects = bucket.objects(s3_path)
      if !s3_objects || s3_objects.empty?
        puts "Failed to find file #{s3_path}"
        exit(false)
      else
        s3_obj = s3_objects.detect {|o| o.key.to_s.rindex(s3_path)}
        s3_file_name = s3_obj.key.to_s[s3_obj.key.to_s.rindex('/') + 1..-1]
        # OK, found the file we are looking for, download it!              
        open(local_file, 'w') do |file|
          AWS::S3::S3Object.stream(s3_obj.key, s3_obj.bucket.name) do |chunk|
            file.write(chunk)
          end                
        end
      end
    end
  end  
end

download(ARGV[0], ARGV[1], ARGV[2], ARGV[3], ARGV[4])