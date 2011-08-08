require "spec_helper"

describe Mongoid::Relations::Embedded::One do

  before do
    [ Person, Shelf ].map(&:delete_all)
  end

  describe "#=" do

    context "when the relation is not cyclic" do

      context "when the parent is a new record" do

        let(:person) do
          Person.new
        end

        let(:name) do
          Name.new
        end

        before do
          person.name = name
        end

        it "sets the target of the relation" do
          person.name.should == name
        end

        it "sets the base on the inverse relation" do
          name.namable.should == person
        end

        it "sets the same instance on the inverse relation" do
          name.namable.should eql(person)
        end

        it "does not save the target" do
          name.should_not be_persisted
        end
      end

      context "when the parent is not a new record" do

        let(:person) do
          Person.create(:ssn => "437-11-1112")
        end

        let(:name) do
          Name.new
        end

        before do
          person.name = name
        end

        it "sets the target of the relation" do
          person.name.should == name
        end

        it "sets the base on the inverse relation" do
          name.namable.should == person
        end

        it "sets the same instance on the inverse relation" do
          name.namable.should eql(person)
        end

        it "saves the target" do
          name.should be_persisted
        end
      end
    end

    context "when the relation is cyclic" do

      context "when the parent is a new record" do

        let(:parent_shelf) do
          Shelf.new
        end

        let(:child_shelf) do
          Shelf.new
        end

        before do
          parent_shelf.child_shelf = child_shelf
        end

        it "sets the target of the relation" do
          parent_shelf.child_shelf.should == child_shelf
        end

        it "sets the base on the inverse relation" do
          child_shelf.parent_shelf.should == parent_shelf
        end

        it "sets the same instance on the inverse relation" do
          child_shelf.parent_shelf.should eql(parent_shelf)
        end

        it "does not save the target" do
          child_shelf.should_not be_persisted
        end
      end

      context "when the parent is not a new record" do

        let(:parent_shelf) do
          Shelf.create
        end

        let(:child_shelf) do
          Shelf.new
        end

        before do
          parent_shelf.child_shelf = child_shelf
        end

        it "sets the target of the relation" do
          parent_shelf.child_shelf.should == child_shelf
        end

        it "sets the base on the inverse relation" do
          child_shelf.parent_shelf.should == parent_shelf
        end

        it "sets the same instance on the inverse relation" do
          child_shelf.parent_shelf.should eql(parent_shelf)
        end

        it "saves the target" do
          child_shelf.should be_persisted
        end
      end
    end
  end

  describe "#= nil" do

    context "when the relation is not cyclic" do

      context "when the parent is a new record" do

        let(:person) do
          Person.new
        end

        let(:name) do
          Name.new
        end

        before do
          person.name = name
          person.name = nil
        end

        it "sets the relation to nil" do
          person.name.should be_nil
        end

        it "removes the inverse relation" do
          name.namable.should be_nil
        end
      end

      context "when the inverse is already nil" do

        let(:person) do
          Person.new
        end

        before do
          person.name = nil
        end

        it "sets the relation to nil" do
          person.name.should be_nil
        end
      end

      context "when the documents are not new records" do

        let(:person) do
          Person.create(:ssn => "437-11-1112")
        end

        let(:name) do
          Name.new
        end

        before do
          person.name = name
          person.name = nil
        end

        it "sets the relation to nil" do
          person.name.should be_nil
        end

        it "removed the inverse relation" do
          name.namable.should be_nil
        end

        it "deletes the child document" do
          name.should be_destroyed
        end
      end
    end

    context "when the relation is cyclic" do

      context "when the parent is a new record" do

        let(:parent_shelf) do
          Shelf.new
        end

        let(:child_shelf) do
          Shelf.new
        end

        before do
          parent_shelf.child_shelf = child_shelf
          parent_shelf.child_shelf = nil
        end

        it "sets the relation to nil" do
          parent_shelf.child_shelf.should be_nil
        end

        it "removes the inverse relation" do
          child_shelf.parent_shelf.should be_nil
        end
      end

      context "when the inverse is already nil" do

        let(:parent_shelf) do
          Shelf.new
        end

        before do
          parent_shelf.child_shelf = nil
        end

        it "sets the relation to nil" do
          parent_shelf.child_shelf.should be_nil
        end
      end

      context "when the documents are not new records" do

        let(:parent_shelf) do
          Shelf.create
        end

        let(:child_shelf) do
          Shelf.new
        end

        before do
          parent_shelf.child_shelf = child_shelf
          parent_shelf.child_shelf = nil
        end

        it "sets the relation to nil" do
          parent_shelf.child_shelf.should be_nil
        end

        it "removed the inverse relation" do
          child_shelf.parent_shelf.should be_nil
        end

        it "deletes the child document" do
          child_shelf.should be_destroyed
        end
      end
    end
  end

  describe "#build_#\{name}" do

    context "when the relation is not cyclic" do

      context "when the parent is a new record" do

        context "when not providing any attributes" do

          context "when building once" do

            let(:person) do
              Person.new
            end

            let!(:name) do
              person.build_name
            end

            it "sets the target of the relation" do
              person.name.should == name
            end

            it "sets the base on the inverse relation" do
              name.namable.should == person
            end

            it "sets no attributes" do
              name.first_name.should be_nil
            end

            it "does not save the target" do
              name.should_not be_persisted
            end
          end

          context "when building twice" do

            let(:person) do
              Person.new
            end

            let!(:name) do
              person.build_name
              person.build_name
            end

            it "sets the target of the relation" do
              person.name.should == name
            end

            it "sets the base on the inverse relation" do
              name.namable.should == person
            end

            it "sets no attributes" do
              name.first_name.should be_nil
            end

            it "does not save the target" do
              name.should_not be_persisted
            end
          end
        end

        context "when passing nil as the attributes" do

          let(:person) do
            Person.new
          end

          let!(:name) do
            person.build_name(nil)
          end

          it "sets the target of the relation" do
            person.name.should == name
          end

          it "sets the base on the inverse relation" do
            name.namable.should == person
          end

          it "sets no attributes" do
            name.first_name.should be_nil
          end

          it "does not save the target" do
            name.should_not be_persisted
          end
        end

        context "when providing attributes" do

          let(:person) do
            Person.new
          end

          let!(:name) do
            person.build_name(:first_name => "James")
          end

          it "sets the target of the relation" do
            person.name.should == name
          end

          it "sets the base on the inverse relation" do
            name.namable.should == person
          end

          it "sets the attributes" do
            name.first_name.should == "James"
          end

          it "does not save the target" do
            name.should_not be_persisted
          end
        end
      end

      context "when the parent is not a new record" do

        let(:person) do
          Person.create(:ssn => "437-11-1112")
        end

        let!(:name) do
          person.build_name(:first_name => "James")
        end

        it "does not save the target" do
          name.should_not be_persisted
        end
      end
    end

    context "when the relation is cyclic" do

      context "when the parent is a new record" do

        let(:parent_shelf) do
          Shelf.new
        end

        let!(:child_shelf) do
          parent_shelf.build_child_shelf(:level => 1)
        end

        it "sets the target of the relation" do
          parent_shelf.child_shelf.should == child_shelf
        end

        it "sets the base on the inverse relation" do
          child_shelf.parent_shelf.should == parent_shelf
        end

        it "sets the attributes" do
          child_shelf.level.should == 1
        end

        it "does not save the target" do
          child_shelf.should_not be_persisted
        end
      end

      context "when the parent is not a new record" do

        let(:parent_shelf) do
          Shelf.create
        end

        let!(:child_shelf) do
          parent_shelf.build_child_shelf(:level => 2)
        end

        it "does not save the target" do
          child_shelf.should_not be_persisted
        end
      end
    end
  end

  describe "#create_#\{name}" do

    context "when the parent is a new record" do

      context "when not providing any attributes" do

        let(:person) do
          Person.new
        end

        let!(:name) do
          person.create_name
        end

        it "sets the target of the relation" do
          person.name.should == name
        end

        it "sets the base on the inverse relation" do
          name.namable.should == person
        end

        it "sets no attributes" do
          name.first_name.should be_nil
        end

        it "saves the target" do
          name.should be_persisted
        end
      end

      context "when passing nil as the attributes" do

        let(:person) do
          Person.new
        end

        let!(:name) do
          person.create_name(nil)
        end

        it "sets the target of the relation" do
          person.name.should == name
        end

        it "sets the base on the inverse relation" do
          name.namable.should == person
        end

        it "sets no attributes" do
          name.first_name.should be_nil
        end

        it "saves the target" do
          name.should be_persisted
        end
      end

      context "when providing attributes" do

        let(:person) do
          Person.new
        end

        let!(:name) do
          person.create_name(:first_name => "James")
        end

        it "sets the target of the relation" do
          person.name.should == name
        end

        it "sets the base on the inverse relation" do
          name.namable.should == person
        end

        it "sets the attributes" do
          name.first_name.should == "James"
        end

        it "saves the target" do
          name.should be_persisted
        end
      end

      context "when the parent is not a new record" do

        let(:person) do
          Person.create(:ssn => "437-11-1112")
        end

        let!(:name) do
          person.create_name(:first_name => "James")
        end

        it "does not save the target" do
          name.should be_persisted
        end
      end
    end
  end

  context "when replacing the relation with another" do

    let!(:person) do
      Person.create(:ssn => "354-21-9678")
    end

    let!(:patient) do
      Patient.create(:title => "Sick")
    end

    let!(:name) do
      person.create_name(:first_name => "Karl")
    end

    before do
      patient.name = person.name
    end

    it "sets the same documents" do
      patient.name.should eq(name)
    end

    it "sets a cloned relation" do
      patient.name.should_not equal(person.name)
    end

    it "does not remove the previous reference" do
      person.name.should eq(name)
    end

    context "when reloading" do

      before do
        person.reload
        patient.reload
      end

      it "sets the same documents" do
        patient.name.should eq(name)
      end

      it "sets a cloned relation" do
        patient.name.should_not equal(person.name)
      end

      it "does not remove the previous reference" do
        person.name.should eq(name)
      end
    end
  end
end
