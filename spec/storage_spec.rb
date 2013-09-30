require 'spec_helper'

describe CiCache::Storage do
  let(:context) { double "context" }
  let(:storage) { CiCache::Storage.new(context) }
  let(:object) { double "object" }
  let(:name) { "file" }

  before do
    context.stub(:log)
  end

  describe :download do
    let(:folder) { "~" }
    let(:handle) { double "handle" }
    subject { storage.download(name, folder) }

    context "when the object exists" do

      it "downloads the object" do
        storage.should_receive(:bucket_object).with(name).and_return(object)
        object.should_receive(:read).and_yield("chunk")
        handle.should_receive(:write).with("chunk")
        File.should_receive(:open).with("~/file", "wb").and_yield(handle)
        subject
      end

      it "uses a defined prefix" do
        storage.should_receive(:prefix).and_return("my-repo/")
        storage.should_receive(:bucket_object).with("my-repo/" + name).and_return(object)
        object.should_receive(:read).and_yield("chunk")
        handle.should_receive(:write).with("chunk")
        File.should_receive(:open).with("~/file", "wb").and_yield(handle)
        subject
      end
    end

    context "when the object doesn't exist" do
      it "logs an error" do
        storage.should_receive(:bucket_object).and_raise(AWS::S3::Errors::AccessDenied.new)
        context.should_receive(:log)
        subject
      end
    end
  end

  describe :upload do
    subject { storage.upload(name, "content") }

    it "uploads the content" do
      storage.should_receive(:bucket_object).with(name).and_return(object)
      object.should_receive(:write).with("content")
      subject
    end

    it "uses a defined prefix" do
      storage.should_receive(:prefix).and_return("my-repo/")
      storage.should_receive(:bucket_object).with("my-repo/" + name).and_return(object)
      object.should_receive(:write).with("content")
      subject
    end
  end
end
