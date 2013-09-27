require 'spec_helper'

describe CiCache::Set do
  describe :run do
    let(:context) { double "context" }
    let(:set) { CiCache::Set.new(context) }
    let(:storage) { double "storage" }
    subject { set.run }

    before do
      CiCache.stub(:shell)
      context.stub(:cache_archive_name).and_return("cache.tar.gz")
      context.stub(:cache_hash_file_name).and_return("cache.sha2")
      context.stub(:hash_file).and_return("Gemfile")
      context.stub(:archive_path).and_return("~/archive.tar.gz")
      context.stub(:old_hash_file).and_return("~/cache.sha2")
      context.stub(:content).and_return("~/.bundle_cache")
      context.stub(:log)

      storage.stub(:upload)
      CiCache::Storage.should_receive(:new).and_return(storage)
    end

    context "when content has changed" do
      it "archives the folder" do
        CiCache.should_receive(:shell).with("tar -cjf ~/archive.tar.gz ~/.bundle_cache")
        subject
      end

      it "uploads the archive" do
        storage.should_receive(:upload).with("cache.tar.gz", "~/archive.tar.gz")
        subject
      end

      it "uploads the hash file" do
        storage.should_receive(:upload).with("cache.sha2", Digest::SHA2.file("Gemfile").hexdigest)
        subject
      end
    end

    context "when content has not changed" do
      it "logs a message" do
        context.should_receive(:log)
        subject
      end
    end
  end
end
