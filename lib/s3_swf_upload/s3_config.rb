module S3SwfUpload
  class S3Config
    require 'yaml'

    cattr_reader :access_key_id, :secret_access_key
    cattr_accessor :bucket, :max_file_size, :acl

    def self.load_config
      if ENV['RACK_ENV'] = 'production'
        @@access_key_id     = ENV['AMAZON_ACCESS_KEY_ID']
        @@secret_access_key = ENV['AMAZON_SECRET_ACCESS_KEY']
        @@bucket            = ENV['AMAZON_S3_SWF_UPLOAD_BUCKET']
        @@max_file_size     = ENV['AMAZON_S3_SWF_MAX_FILE_SIZE']  || 10485760
        @@acl               = ENV['AMAZON_S3_SWF_UPLOAD_ACL']     || 'private'
        
        unless @@access_key_id && @@secret_access_key && @@bucket
          raise "Please configure your environmental variables to include AMAZON_ACCESS_KEY_ID, AMAZON_SECRET_ACCESS_KEY, and AMAZON_S3_SWF_UPLOAD_BUCKET."
        end
      else
        begin
          filename = "#{Rails.root}/config/amazon_s3.yml"
          file = File.open(filename)
          config = YAML.load(file)[Rails.env]

          if config == nil
            raise "Could not load config options for #{Rails.env} from #{filename}."
          end

          @@access_key_id     = config['access_key_id']
          @@secret_access_key = config['secret_access_key']
          @@bucket            = config['bucket']
          @@max_file_size     = config['max_file_size']
          @@acl               = config['acl'] || 'private'



          unless @@access_key_id && @@secret_access_key && @@bucket
            raise "Please configure your S3 settings in #{filename} before continuing so that S3 SWF Upload can function properly."
          end
        rescue Errno::ENOENT
           # No config file yet. Not a big deal. Just issue a warning
           puts "WARNING: You are using the S3 SWF Uploader gem, which wants a config file at #{filename}, " +
              "but none could be found. You should try running 'rails generate s3_swf_upload:uploader'"
        end
      end
    end
  end
end
