require 'ci-cache/error'
require 'optparse'
require 'pathname'

module CiCache
  class CLI
    def self.run(argv)
      new(argv).run
    end

    attr_reader :options, :argv, :path
    attr_accessor :options, :fold_count
    attr_accessor :command, :client

    VALID_COMMANDS = ['get', 'set']

    def initialize(argv = nil)
      @argv    = argv || ARGV
      @options = {}
      @path    = []
      self.fold_count = 0
    end

    def run
      parse!
      execute_command
    rescue Error => error
      options[:debug] ? raise(error) : die(error.message)
    end

    def fold(message)
      self.fold_count += 1
      print "travis_fold:start:ci-cache.#{fold_count}\r" if options[:fold]
      puts "\e[33m#{message}\e[0m"
      yield
    ensure
      print "\ntravis_fold:end:ci-cache.#{fold_count}\r" if options[:fold]
    end

    def content
      error("No valid content provided") unless options[:content]
      options[:content]
    end

    def name
      error("No valid name provided") unless options[:name]
      options[:name]
    end

    def hash_file
      error("No hash file provided") unless options[:hash_file]
      Pathname(options[:hash_file]).expand_path
    end

    def output_path
      error("No output path provided") unless options[:output_path]
      Pathname(options[:output_path]).expand_path
    end

    def cache_archive_name
      "#{name}.tar.gz"
    end

    def cache_hash_file_name
      "#{name}.sha2"
    end

    def tmp_folder
      Pathname("~").expand_path
    end

    def archive_path
      Pathname("#{tmp_folder}/#{cache_archive_name}")
    end

    def old_hash_file
      Pathname("#{tmp_folder}/#{cache_hash_file_name}")
    end

    def log(message)
      $stderr.puts(message)
    end

    private

    def execute_command
      if VALID_COMMANDS.include? command
        send(command)
        return 0
      else
        error "Invalid command."
        return 1
      end
    end

    def get
      fold("Getting #{name}") do
        CiCache::Get.new(self).run
      end
    end

    def set
      fold("Setting #{name}") do
        CiCache::Set.new(self).run
      end
    end

    def error(message)
      raise Error, message
    end

    def die(message)
      $stderr.puts(message)
      exit 1
    end

    def parse!
      self.command = argv[0]
      parser.parse! argv
    end

    def parser
      @opt_parser ||= begin
        options = self.options

        OptionParser.new do |opt|
          opt.banner = 'Usage: ci-cache COMMAND [OPTIONS]'
          opt.separator  ''
          opt.separator  'Commands'
          opt.separator  '     get: get files from cache'
          opt.separator  '     set: cache files'
          opt.separator  ''
          opt.separator  'Options'

          opt.on('--name NAME','archive name') do |name|
            options[:name] = name
          end

          opt.on('--content CONTENT','path or file to cache') do |content|
            options[:content] = content
          end

          opt.on('--hash-file HASH_FILE', 'file used to check for updates') do |target_path|
            options[:hash_file] = target_path
          end

          opt.on('--output-path OUTPUT_PATH', 'path the archive should be extracted to') do |output_path|
            options[:output_path] = output_path
          end

          opt.on('-h','--help','help') do
            puts @opt_parser
          end
        end
      end
    end
  end
end
