module CiCache
  class Storage

    def initialize(context)
      configure_aws
      @s3 = AWS::S3.new
      @context = context
    end

    def download(name, tmp_folder)
      target_file = "#{tmp_folder}/#{name}"
      log "Download: #{name} ~> #{target_file}"
      object = bucket_object(name)
      File.open(target_file, 'wb') do |file|
        object.read do |chunk|
           file.write(chunk)
        end
      end
    rescue AWS::S3::Errors::AccessDenied => e
      log "Not found."
    end

    def upload(name, content)
      log "Upload: #{name}"
      object = bucket_object(name)
      object.write(content)
    end

    private

    def log(message)
      @context.log(message)
    end

    def bucket_name
      ENV["CI_CACHE_S3_BUCKET"]
    end

    def configure_aws
      AWS.config(
        access_key_id: ENV["CI_CACHE_S3_KEY"],
        secret_access_key: ENV["CI_CACHE_S3_SECRET"]
      )
    end

    def bucket_object(name)
      bucket.objects[name]
    end

    def bucket
      @s3.buckets[bucket_name]
    end
  end
end
