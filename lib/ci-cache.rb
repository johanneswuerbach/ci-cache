require 'aws-sdk'

module CiCache
  autoload :CLI,     'ci-cache/cli'
  autoload :Get,     'ci-cache/get'
  autoload :Set,     'ci-cache/set'
  autoload :Error,   'ci-cache/error'
  autoload :Storage, 'ci-cache/storage'

  def self.shell(command)
    system(command)
  end
end
