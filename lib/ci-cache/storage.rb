module CiCache
  class Storage

    def initialize(context)
      configure_aws
      @s3 = AWS::S3.new
      @context = context
    end

    def download(name, tmp_folder)
      target_file = "#{tmp_folder}/#{name}"
      prefixed_name = prefixed_name(name)
      log "Download: #{prefixed_name} ~> #{target_file}"
      object = bucket_object(prefixed_name)
      File.open(target_file, 'wb') do |file|
        object.read do |chunk|
           file.write(chunk)
        end
      end
    rescue AWS::S3::Errors::AccessDenied => e
      log "Not found."
    end

    def upload(name, content)
      prefixed_name = prefixed_name(name)
      log "Upload: #{prefixed_name}"
      object = bucket_object(prefixed_name)
      object.write(content)
    end

    private

    def prefixed_name(name)
      prefix + name
    end

    def log(message)
      @context.log(message)
    end

    def bucket_name
      ENV["CI_CACHE_S3_BUCKET"]
    end

    def prefix
      ENV["CI_CACHE_S3_PREFIX"] || ""
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
