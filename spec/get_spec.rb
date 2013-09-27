require 'spec_helper'

describe CiCache::Get do
  describe :run do
    let(:context) { double "context" }
    let(:get) { CiCache::Get.new(context) }
    let(:storage) { double "storage" }
    subject { get.run }

    before do
      CiCache.stub(:shell)
      context.stub(:cache_archive_name).and_return("cache.tar.gz")
      context.stub(:cache_hash_file_name).and_return("cache.sha2")
      context.stub(:archive_path).and_return(Pathname("~/cache.tar.gz"))
      context.stub(:tmp_folder).and_return("~")
      context.stub(:output_path).and_return("~")
      context.stub(:log)

      storage.stub(:download)
      CiCache::Storage.should_receive(:new).and_return(storage)
    end

    it "downloads the archive" do
      storage.should_receive(:download).with("cache.tar.gz", "~")
      subject
    end

    it "download the hash file" do
      storage.should_receive(:download).with("cache.sha2", "~")
      subject
    end

    it "extracts the archive" do
      CiCache.should_receive(:shell).with("tar -C ~ -xf ~/cache.tar.gz")
      subject
    end
  end
end
