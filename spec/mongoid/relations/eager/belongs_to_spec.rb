require "spec_helper"

describe Mongoid::Relations::Eager::BelongsTo do

  let(:person) do
    Person.create!
  end

  let!(:post) do
    Post.create!(person: person)
  end

  let(:person_metadata) do
    Post.reflect_on_association(:person)
  end

  let(:docs) do
    Post.all.to_a
  end

  let(:eager) do
    described_class.new(Post, [person_metadata], docs).tap do |b|
      b.shift_relation
    end
  end

  describe ".grouped_docs" do

    it "aggregates by the perent id" do
      expect(eager.grouped_docs.keys).to eq([person.id])
    end
  end

  describe ".set_on_parent" do

    it "sets the relation into the parent" do
      docs.each do |doc|
        expect(doc).to receive(:set_relation).with(:person, :foo)
      end
      eager.set_on_parent(person.id, :foo)
    end
  end

  describe ".includes" do

    before do
      3.times { |i| Account.create!(person: person, name: "savings#{i}") }
    end

    context "when including the belongs_to relation" do

      it "queries twice" do

        expect_query(2) do
          Account.all.includes(:person).each do |account|
            expect(account.person).to_not be_nil
          end
        end
      end
    end


  end

end
