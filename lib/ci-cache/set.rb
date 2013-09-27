require "digest"

module CiCache
  class Set
    def initialize(context)
      @context = context
      @storage = Storage.new(context)
    end

    def run
      if content_has_changed?
        context.log("Updating cache.")
        archive_files
        upload_archive
        upload_hash_file
      else
        context.log("Nothing changed.")
      end
    end

    private

    def context
      @context
    end

    def archive_files
      log "Archive: #{content} ~> #{archive_path}"
      CiCache.shell("tar -cjf #{archive_path} #{content}")
    end

    def content_has_changed?
      new_checksum != old_checksum
    end

    def new_checksum
      @_new_checksum ||= Digest::SHA2.file(context.hash_file).hexdigest
    end

    def old_checksum
      old_hash_file = context.old_hash_file
      File.exists?(old_hash_file) ? File.read(old_hash_file) : ""
    end

    def upload_archive
      @storage.upload(context.cache_archive_name, context.archive_path)
    end

    def upload_hash_file
      @storage.upload(context.cache_hash_file_name, new_checksum)
    end

    def archive_path
      context.archive_path
    end

    def content
      context.content
    end

    def log(message)
      context.log(message)
    end
  end
end
