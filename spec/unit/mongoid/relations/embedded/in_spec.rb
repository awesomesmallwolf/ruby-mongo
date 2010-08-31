require "spec_helper"

describe Mongoid::Relations::Embedded::In do

  let(:klass) do
    Mongoid::Relations::Embedded::In
  end

  let(:base) do
    Name.new
  end

  describe ".builder" do

    let(:builder_klass) do
      Mongoid::Relations::Builders::Embedded::In
    end

    let(:document) do
      stub
    end

    let(:metadata) do
      stub(:extension? => false)
    end

    it "returns the embedded in builder" do
      klass.builder(metadata, document).should
        be_a_kind_of(builder_klass)
    end
  end

  describe ".embedded?" do

    it "returns true" do
      klass.should be_embedded
    end
  end

  describe ".macro" do

    it "returns embedded_in" do
      klass.macro.should == :embedded_in
    end
  end

  context "properties" do

    let(:document) do
      stub
    end

    let(:metadata) do
      stub(:extension? => false)
    end

    let(:relation) do
      klass.new(base, document, metadata)
    end

    before do
      document.expects(:to_a).returns([ document ])
      document.expects(:metadata=).with(metadata)
    end

    describe "#metadata" do

      it "returns the relation's metadata" do
        relation.metadata.should == metadata
      end
    end

    describe "#target" do

      it "returns the relation's target" do
        relation.target.should == document
      end
    end
  end

  describe "#substitute" do

    let(:document) do
      stub
    end

    let(:metadata) do
      stub(:extension? => false)
    end

    let(:relation) do
      klass.new(base, document, metadata)
    end

    before do
      document.expects(:to_a).returns([ document ])
      document.expects(:metadata=).with(metadata)
    end

    context "when the target is nil" do

      it "returns nil" do
        relation.substitute(nil).should be_nil
      end
    end

    context "when the target is not nil" do

      let(:new_doc) do
        stub
      end

      it "replaces the target" do
        relation.substitute(new_doc)
        relation.target.should == new_doc
      end

      it "returns self" do
        relation.substitute(new_doc).should == new_doc
      end
    end
  end
end
