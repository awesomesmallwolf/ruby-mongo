require File.join(File.dirname(__FILE__), "/../../../spec_helper.rb")

describe Mongoid::Associations::HasManyAssociation do

  before do
    @first_id = Mongo::ObjectID.new
    @second_id = Mongo::ObjectID.new
    @attributes = { :addresses => [
      { :_id => @first_id, :street => "Street 1" },
      { :_id => @second_id, :street => "Street 2" } ] }
    @document = stub(:attributes => @attributes, :add_observer => true, :update => true)
  end

  describe "#[]" do

    before do
      @association = Mongoid::Associations::HasManyAssociation.new(:addresses, @document)
    end

    context "when the index is present in the association" do

      it "returns the document at the index" do
        @association[0].should be_a_kind_of(Address)
        @association[0].street.should == "Street 1"
      end

    end

    context "when the index is not present in the association" do

      it "returns nil" do
        @association[3].should be_nil
      end

    end

  end

  describe "#<<" do

    before do
      @association = Mongoid::Associations::HasManyAssociation.new(:addresses, @document)
      @address = Address.new
    end

    it "adds the parent document before appending to the array" do
      @association << @address
      @association.length.should == 3
      @address.parent.should == @document
    end

  end

  describe "#concat" do

    before do
      @association = Mongoid::Associations::HasManyAssociation.new(:addresses, @document)
      @address = Address.new
    end

    it "adds the parent document before appending to the array" do
      @association.concat [@address]
      @association.length.should == 3
      @address.parent.should == @document
    end

  end

  describe "#push" do

    before do
      @association = Mongoid::Associations::HasManyAssociation.new(:addresses, @document)
      @address = Address.new
    end

    it "adds the parent document before appending to the array" do
      @association.push @address
      @association.length.should == 3
      @address.parent.should == @document
    end

  end

  describe "#build" do

    before do
      @association = Mongoid::Associations::HasManyAssociation.new(:addresses, @document)
    end

    it "adds a new document to the array with the suppied parameters" do
      @association.build({ :street => "Street 1" })
      @association.length.should == 3
      @association[2].should be_a_kind_of(Address)
      @association[2].street.should == "Street 1"
    end

    it "returns the newly built object in the association" do
      address = @association.build({ :street => "Yet Another" })
      address.should be_a_kind_of(Address)
      address.street.should == "Yet Another"
    end

  end

  describe "#find" do

    before do
      @association = Mongoid::Associations::HasManyAssociation.new(:addresses, @document)
    end

    context "when finding all" do

      it "returns all the documents" do
        @association.find(:all).should == @association
      end

    end

    context "when finding by id" do

      it "returns the document in the array with that id" do
        address = @association.find(@second_id)
        address.id.should == @second_id
      end

    end

  end

  describe "#first" do

    context "when there are elements in the array" do

      before do
        @association = Mongoid::Associations::HasManyAssociation.new(:addresses, @document)
      end

      it "returns the first element" do
        @association.first.should be_a_kind_of(Address)
        @association.first.street.should == "Street 1"
      end

    end

    context "when the array is empty" do

      before do
        @association = Mongoid::Associations::HasManyAssociation.new(:addresses, Person.new)
      end

      it "returns nil" do
        @association.first.should be_nil
      end

    end

  end

  describe "#length" do

    context "#length" do

      it "returns the length of the delegated array" do
        @association = Mongoid::Associations::HasManyAssociation.new(:addresses, @document)
        @association.length.should == 2
      end

    end

  end

  describe "#push" do

    before do
      @association = Mongoid::Associations::HasManyAssociation.new(:addresses, @document)
    end

    it "appends the document to the end of the array" do
      @association.push(Address.new)
      @association.length.should == 3
    end

  end

end
