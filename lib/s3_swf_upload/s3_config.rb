module S3SwfUpload
  class S3Config
    require 'yaml'

    cattr_reader :access_key_id, :secret_access_key
    cattr_accessor :bucket, :max_file_size, :acl

    def self.load_config
      begin
        filename = "#{Rails.root}/config/amazon_s3.yml"
        file = File.open(filename)
        config = YAML.load(file)[Rails.env]

        @@access_key_id     = ENV['AMAZON_ACCESS_KEY_ID']        || config['access_key_id']
        @@secret_access_key = ENV['AMAZON_SECRET_ACCESS_KEY']    || config['secret_access_key']
        @@bucket            = ENV['AMAZON_S3_SWF_UPLOAD_BUCKET'] || config['bucket']
        @@max_file_size     = ENV['AMAZON_S3_SWF_MAX_FILE_SIZE'] || config['max_file_size']
        @@acl               = ENV['AMAZON_S3_SWF_UPLOAD_ACL']    || config['acl'] || 'private'

        unless @@access_key_id && @@secret_access_key && @@bucket
          raise "Please configure your S3 settings in #{filename} or in environment variables before continuing so that S3 SWF Upload can function properly."
        end
      rescue Errno::ENOENT
         # No config file yet. Not a big deal. Just issue a warning
         puts "WARNING: You are using the S3 SWF Uploader gem, which wants a config file at #{filename}, " +
            "but none could be found. You should try running 'rails generate s3_swf_upload:uploader'"
      end
    end
  end
end
