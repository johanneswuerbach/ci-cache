module CiCache
  class Get

    def initialize(context)
      @context = context
      @storage = Storage.new(context)
    end

    def run
      download_archive
      download_hash_file
      extract_archive
    end

    private

    def download_archive
      @storage.download(context.cache_archive_name, tmp_folder)
    end

    def download_hash_file
      @storage.download(context.cache_hash_file_name, tmp_folder)
    end

    def extract_archive
      log "Extract: #{archive_path} ~> #{output_path}"
      CiCache.shell("tar -C #{output_path} -xf #{archive_path}")
    end

    def context
      @context
    end

    def log(message)
      context.log(message)
    end

    def tmp_folder
      context.tmp_folder
    end

    def archive_path
      context.archive_path
    end

    def output_path
      context.output_path
    end
  end
end
