require "spec_helper"

describe Mongoid::Relations::Targets::Enumerable do

  before do
    [ Person, Post ].each(&:delete_all)
  end

  describe "#==" do

    context "when comparing with an enumerable" do

      let(:person) do
        Person.create(:ssn => "543-98-1234")
      end

      let!(:post) do
        Post.create(:person_id => person.id)
      end

      context "when only a criteria target exists" do

        let(:criteria) do
          Post.where(:person_id => person.id)
        end

        let!(:enumerable) do
          described_class.new(criteria)
        end

        it "returns the equality check" do
          enumerable.should eq([ post ])
        end
      end

      context "when only an array target exists" do

        let!(:enumerable) do
          described_class.new([ post ])
        end

        it "returns the equality check" do
          enumerable.loaded.should eq([ post ])
        end
      end

      context "when a criteria and added exist" do

        let(:criteria) do
          Post.where(:person_id => person.id)
        end

        let(:enumerable) do
          described_class.new(criteria)
        end

        let(:post_two) do
          Post.new
        end

        context "when the added does not contain unloaded docs" do

          before do
            enumerable << post_two
          end

          it "returns the equality check" do
            enumerable.should eq([ post, post_two ])
          end
        end

        context "when the added contains unloaded docs" do

          before do
            enumerable << post
          end

          it "returns the equality check" do
            enumerable.should eq([ post ])
          end
        end
      end
    end

    context "when comparing with a non enumerable" do

      let(:enumerable) do
        described_class.new([])
      end

      it "returns false" do
        enumerable.should_not eq("person")
      end
    end
  end

  describe "#<<" do

    let(:person) do
      Person.create(:ssn => "543-98-1234")
    end

    let!(:post) do
      Post.create(:person_id => person.id)
    end

    let!(:enumerable) do
      described_class.new([])
    end

    let!(:added) do
      enumerable << post
    end

    it "adds the document to the added target" do
      enumerable.added.should eq([ post ])
    end

    it "returns the added documents" do
      added.should eq([ post ])
    end
  end

  describe "#clear" do

    let(:person) do
      Person.create(:ssn => "543-98-1234")
    end

    let!(:post) do
      Post.create(:person_id => person.id)
    end

    let!(:post_two) do
      Post.create(:person_id => person.id)
    end

    let(:criteria) do
      Post.where(:person_id => person.id)
    end

    let(:enumerable) do
      described_class.new(criteria)
    end

    before do
      enumerable.loaded << post
      enumerable << post
    end

    let!(:clear) do
      enumerable.clear do |doc|
        doc.should be_a(Post)
      end
    end

    it "clears out the loaded docs" do
      enumerable.loaded.should be_empty
    end

    it "clears out the added docs" do
      enumerable.added.should be_empty
    end

    it "retains its loaded state" do
      enumerable.should_not be_loaded
    end
  end

  describe "#delete" do

    let(:person) do
      Person.create(:ssn => "543-98-1234")
    end

    context "when the document is loaded" do

      let!(:post) do
        Post.create(:person_id => person.id)
      end

      let!(:enumerable) do
        described_class.new([ post ])
      end

      let!(:deleted) do
        enumerable.delete(post)
      end

      it "deletes the document from the enumerable" do
        enumerable.loaded.should be_empty
      end

      it "returns the document" do
        deleted.should eq(post)
      end
    end

    context "when the document is added" do

      let!(:post) do
        Post.new
      end

      let(:criteria) do
        Person.where(:person_id => person.id)
      end

      let!(:enumerable) do
        described_class.new(criteria)
      end

      before do
        enumerable << post
      end

      let!(:deleted) do
        enumerable.delete(post)
      end

      it "removes the document from the added docs" do
        enumerable.added.should be_empty
      end

      it "returns the document" do
        deleted.should eq(post)
      end
    end

    context "when the document is unloaded" do

      let!(:post) do
        Post.create(:person_id => person.id)
      end

      let(:criteria) do
        Post.where(:person_id => person.id)
      end

      let!(:enumerable) do
        described_class.new(criteria)
      end

      let!(:deleted) do
        enumerable.delete(post)
      end

      it "does not load the document" do
        enumerable.loaded.should be_empty
      end

      it "returns the document" do
        deleted.should eq(post)
      end
    end

    context "when the document is not found" do

      let!(:post) do
        Post.create(:person_id => person.id)
      end

      let(:criteria) do
        Person.where(:person_id => person.id)
      end

      let!(:enumerable) do
        described_class.new([ post ])
      end

      let!(:deleted) do
        enumerable.delete(Post.new) do |doc|
          doc.should be_nil
        end
      end

      it "returns nil" do
        deleted.should be_nil
      end
    end
  end

  describe "#delete_if" do

    let(:person) do
      Person.create(:ssn => "543-98-1234")
    end

    context "when the document is loaded" do

      let!(:post) do
        Post.create(:person_id => person.id)
      end

      let!(:enumerable) do
        described_class.new([ post ])
      end

      let!(:deleted) do
        enumerable.delete_if { |doc| doc == post }
      end

      it "deletes the document from the enumerable" do
        enumerable.loaded.should be_empty
      end

      it "returns the remaining docs" do
        deleted.should eq([])
      end
    end

    context "when the document is added" do

      let!(:post) do
        Post.new
      end

      let(:criteria) do
        Person.where(:person_id => person.id)
      end

      let!(:enumerable) do
        described_class.new(criteria)
      end

      before do
        enumerable << post
      end

      let!(:deleted) do
        enumerable.delete_if { |doc| doc == post }
      end

      it "removes the document from the added docs" do
        enumerable.added.should be_empty
      end

      it "returns the remaining docs" do
        deleted.should eq([])
      end
    end

    context "when the document is unloaded" do

      let!(:post) do
        Post.create(:person_id => person.id)
      end

      let(:criteria) do
        Post.where(:person_id => person.id)
      end

      let!(:enumerable) do
        described_class.new(criteria)
      end

      let!(:deleted) do
        enumerable.delete_if { |doc| doc == post }
      end

      it "does not load the document" do
        enumerable.loaded.should be_empty
      end

      it "returns the remaining docs" do
        deleted.should eq([])
      end
    end

    context "when the block doesn't match" do

      let!(:post) do
        Post.create(:person_id => person.id)
      end

      let(:criteria) do
        Person.where(:person_id => person.id)
      end

      let!(:enumerable) do
        described_class.new([ post ])
      end

      let!(:deleted) do
        enumerable.delete_if { |doc| doc == Post.new }
      end

      it "returns the remaining docs" do
        deleted.should eq([ post ])
      end
    end
  end

  describe "#each" do

    let(:person) do
      Person.create(:ssn => "543-98-1234")
    end

    let!(:post) do
      Post.create(:person_id => person.id)
    end

    context "when only a criteria target exists" do

      let(:criteria) do
        Post.where(:person_id => person.id)
      end

      let!(:enumerable) do
        described_class.new(criteria)
      end

      let!(:iterated) do
        enumerable.each do |doc|
          doc.should be_a(Post)
        end
      end

      it "loads each document" do
        enumerable.loaded.should eq([ post ])
      end

      it "becomes loaded" do
        enumerable.should be_loaded
      end
    end

    context "when only an array target exists" do

      let!(:enumerable) do
        described_class.new([ post ])
      end

      let!(:iterated) do
        enumerable.each do |doc|
          doc.should be_a(Post)
        end
      end

      it "does not alter the loaded docs" do
        enumerable.loaded.should eq([ post ])
      end

      it "stays loaded" do
        enumerable.should be_loaded
      end
    end

    context "when a criteria and added exist" do

      let(:criteria) do
        Post.where(:person_id => person.id)
      end

      let!(:enumerable) do
        described_class.new(criteria)
      end

      let(:post_two) do
        Post.new
      end

      context "when the added does not contain unloaded docs" do

        before do
          enumerable << post_two
        end

        let!(:iterated) do
          enumerable.each do |doc|
            doc.should be_a(Post)
          end
        end

        it "adds the unloaded to the loaded docs" do
          enumerable.loaded.should eq([ post ])
        end

        it "keeps the appended in the added docs" do
          enumerable.added.should eq([ post_two ])
        end

        it "stays loaded" do
          enumerable.should be_loaded
        end
      end

      context "when the added contains unloaded docs" do

        before do
          enumerable << post
        end

        let!(:iterated) do
          enumerable.each do |doc|
            doc.should be_a(Post)
          end
        end

        it "does not add the unloaded to the loaded docs" do
          enumerable.loaded.should eq([])
        end

        it "keeps the appended in the added docs" do
          enumerable.added.should eq([ post ])
        end

        it "stays loaded" do
          enumerable.should be_loaded
        end
      end
    end
  end

  describe "#initialize" do

    let(:person) do
      Person.new
    end

    context "when provided with a criteria" do

      let(:criteria) do
        Post.where(:person_id => person.id)
      end

      let(:enumerable) do
        described_class.new(criteria)
      end

      it "sets the criteria" do
        enumerable.unloaded.should eq(criteria)
      end

      it "is not loaded" do
        enumerable.should_not be_loaded
      end
    end

    context "when provided an array" do

      let(:post) do
        Post.new
      end

      let(:enumerable) do
        described_class.new([ post ])
      end

      it "does not set a criteria" do
        enumerable.unloaded.should be_nil
      end

      it "is loaded" do
        enumerable.should be_loaded
      end
    end
  end

  describe "#in_memory" do

    let(:person) do
      Person.new
    end

    context "when the enumerable is loaded" do

      let(:post) do
        Post.new
      end

      let(:enumerable) do
        described_class.new([ post ])
      end

      let(:post_two) do
        Post.new
      end

      before do
        enumerable << post_two
      end

      let(:in_memory) do
        enumerable.in_memory
      end

      it "returns the loaded and added docs" do
        in_memory.should eq([ post, post_two ])
      end
    end

    context "when the enumerable is not loaded" do

      let(:post) do
        Post.new(:person_id => person.id)
      end

      let(:enumerable) do
        described_class.new(Post.where(:person_id => person.id))
      end

      let(:post_two) do
        Post.new(:person_id => person.id)
      end

      before do
        enumerable << post_two
      end

      let(:in_memory) do
        enumerable.in_memory
      end

      it "returns the added docs" do
        in_memory.should eq([ post_two ])
      end
    end

    context "when passed a block" do

      let(:enumerable) do
        described_class.new(Post.where(:person_id => person.id))
      end

      let(:post_two) do
        Post.new(:person_id => person.id)
      end

      before do
        enumerable << post_two
      end

      it "yields to each in memory document" do
        enumerable.in_memory do |doc|
          doc.should eq(post_two)
        end
      end
    end
  end

  describe "#load_all!" do

    let(:person) do
      Person.create(:ssn => "422-21-9687")
    end

    let!(:post) do
      Post.create(:person_id => person.id)
    end

    let(:criteria) do
      Post.where(:person_id => person.id)
    end

    let!(:enumerable) do
      described_class.new(criteria)
    end

    let!(:loaded) do
      enumerable.load_all!
    end

    it "loads all the unloaded documents" do
      enumerable.loaded.should eq([ post ])
    end

    it "returns true" do
      loaded.should be_true
    end

    it "sets loaded to true" do
      enumerable.should be_loaded
    end
  end

  describe "#reset" do

    let(:person) do
      Person.create(:ssn => "543-98-1238")
    end

    let(:post) do
      Post.create(:person_id => person.id)
    end

    let(:post_two) do
      Post.create(:person_id => person.id)
    end

    let(:enumerable) do
      described_class.new([ post ])
    end

    before do
      enumerable << post_two
    end

    let!(:reset) do
      enumerable.reset
    end

    it "is not loaded" do
      enumerable.should_not be_loaded
    end

    it "clears out the loaded docs" do
      enumerable.loaded.should be_empty
    end

    it "clears out the added docs" do
      enumerable.added.should be_empty
    end
  end

  describe "#size" do

    let(:person) do
      Person.create(:ssn => "543-98-1238")
    end

    let!(:post) do
      Post.create(:person_id => person.id)
    end

    context "when the enumerable is loaded" do

      let(:enumerable) do
        described_class.new([ post ])
      end

      let(:post_two) do
        Post.new(:person_id => person.id)
      end

      before do
        enumerable << post_two
      end

      let(:size) do
        enumerable.size
      end

      it "returns the loaded size plus added size" do
        size.should eq(2)
      end
    end

    context "when the enumerable is not loaded" do

      let(:enumerable) do
        described_class.new(Post.where(:person_id => person.id))
      end

      context "when the added contains new documents" do

        let(:post_two) do
          Post.new(:person_id => person.id)
        end

        before do
          enumerable << post_two
        end

        let(:size) do
          enumerable.size
        end

        it "returns the unloaded count plus added new size" do
          size.should eq(2)
        end
      end

      context "when the added contains persisted documents" do

        let(:post_two) do
          Post.create(:person_id => person.id)
        end

        before do
          enumerable << post_two
        end

        let(:size) do
          enumerable.size
        end

        it "returns the unloaded count plus added new size" do
          size.should eq(2)
        end
      end
    end
  end
end
