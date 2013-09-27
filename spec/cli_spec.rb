require 'spec_helper'

describe CiCache::CLI do

  describe "::new" do
    let(:path) { Pathname("~/").expand_path }
    let(:cli) { CiCache::CLI.new([
      "set",
      "--name", "bundle_cache",
      "--hash-file", "Gemfile",
      "--content", "~/.bundle_cache"
    ])}
    subject { cli }
    before do
      cli.send(:parse!)
    end

    its(:cache_archive_name) { should eq("bundle_cache.tar.gz")}
    its(:cache_hash_file_name) { should eq("bundle_cache.sha2")}
    its(:tmp_folder) { should eq(path) }
    its(:archive_path) { should eq(Pathname("#{path}/bundle_cache.tar.gz"))}
    its(:old_hash_file) { should eq(Pathname("#{path}/bundle_cache.sha2"))}
    its(:hash_file) { should eq(Pathname("Gemfile").expand_path) }
    its(:hash_file) { should eq(Pathname("Gemfile").expand_path) }
  end

  describe "::run" do
    context "when get is used" do
      let(:get) { double "get" }
      subject { CiCache::CLI.run(["get"]) }

      it "should execute the get command" do
        CiCache::Get.should_receive(:new).with(instance_of(CiCache::CLI)).and_return(get)
        CiCache::CLI.any_instance.should_receive(:fold).and_yield
        get.should_receive(:run)
        subject
      end
    end

    context "when set is used" do
      let(:set) { double "set" }
      subject { CiCache::CLI.run(["set"]) }

      it "should execute the set command" do
        CiCache::Set.should_receive(:new).with(instance_of(CiCache::CLI)).and_return(set)
        CiCache::CLI.any_instance.should_receive(:fold).and_yield
        set.should_receive(:run)
        subject
      end
    end
  end
end
