# encoding: utf-8
module Mongoid #:nodoc:
  module Relations #:nodoc:
    module Targets #:nodoc:

      # This class is the wrapper for all relational associations that have a
      # target that can be a criteria or array of loaded documents. This
      # handles both cases or a combination of the two.
      class Enumerable
        include ::Enumerable

        # The three main instance variables are collections of documents.
        #
        # @attribute [r] added Documents that have been appended.
        # @attribute [r] loaded Persisted documents that have been loaded.
        # @attribute [r] unloaded A criteria representing persisted docs.
        attr_reader :added, :loaded, :unloaded

        # Check if the enumerable is equal to the other object.
        #
        # @example Check equality.
        #   enumerable == []
        #
        # @param [ Enumerable ] other The other enumerable.
        #
        # @return [ true, false ] If the objects are equal.
        #
        # @since 2.1.0
        def ==(other)
          return false unless other.respond_to?(:entries)
          entries == other.entries
        end

        # Append a document to the enumerable.
        #
        # @example Append the document.
        #   enumerable << document
        #
        # @param [ Document ] document The document to append.
        #
        # @return [ Document ] The document.
        #
        # @since 2.1.0
        def <<(document)
          added << document
        end
        alias :push :<<

        # Clears out all the documents in this enumerable. If passed a block it
        # will yield to each document that is in memory.
        #
        # @example Clear out the enumerable.
        #   enumerable.clear
        #
        # @example Clear out the enumerable with a block.
        #   enumerable.clear do |doc|
        #     doc.unbind
        #   end
        #
        # @return [ Array<Document> ] The cleared out added docs.
        #
        # @since 2.1.0
        def clear
          if block_given?
            in_memory { |doc| yield(doc) }
          end
          loaded.clear and added.clear
        end

        # Delete the supplied document from the enumerable.
        #
        # @note This operation loads all documents from the database.
        #
        # @example Delete the document.
        #   enumerable.delete(document)
        #
        # @param [ Document ] document The document to delete.
        #
        # @return [ Document ] The deleted document.
        #
        # @since 2.1.0
        def delete(document)
          load_all! and (loaded.delete(document) || added.delete(document)).tap do |doc|
            yield(doc) if block_given?
          end
        end

        # Deletes every document in the enumerable for where the block returns
        # true.
        #
        # @note This operation loads all documents from the database.
        #
        # @example Delete all matching documents.
        #   enumerable.delete_if do |doc|
        #     dod.id == id
        #   end
        #
        # @return [ Array<Document> ] The remaining docs.
        #
        # @since 2.1.0
        def delete_if(&block)
          load_all! and loaded.delete_if(&block) + added.delete_if(&block)
        end

        # Iterating over this enumerable has to handle a few different
        # scenarios.
        #
        # If the enumerable has its criteria loaded into memory then it yields
        # to all the loaded docs and all the added docs.
        #
        # If the enumerable has not loaded the criteria then it iterates over
        # the cursor while loading the documents and then iterates over the
        # added docs.
        #
        # @example Iterate over the enumerable.
        #   enumerable.each do |doc|
        #     puts doc
        #   end
        #
        # @return [ true ] That the enumerable is now loaded.
        #
        # @since 2.1.0
        def each
          if loaded?
            loaded.each { |doc| yield(doc) }
          else
            unloaded.each do |doc|
              loaded.push(doc) and yield(doc) unless added.include?(doc)
            end
          end
          added.each { |doc| yield(doc) }
          @executed = true
        end

        # Initialize the new enumerable either with a criteria or an array.
        #
        # @example Initialize the enumerable with a criteria.
        #   Enumberable.new(Post.where(:person_id => id))
        #
        # @example Initialize the enumerable with an array.
        #   Enumerable.new([ post ])
        #
        # @param [ Criteria, Array<Document> ] target The wrapped object.
        #
        # @since 2.1.0
        def initialize(target)
          if target.is_a?(Criteria)
            @added, @loaded, @unloaded = [], [], target
          else
            @added, @executed, @loaded = [], true, target
          end
        end

        # Inspection will just inspect the entries for nice array-style
        # printing.
        #
        # @example Inspect the enumerable.
        #   enumerable.inspect
        #
        # @return [ String ] The inspected enum.
        #
        # @since 2.1.0
        def inspect
          entries.inspect
        end

        # Return all the documents in the enumerable that have been loaded or
        # added.
        #
        # @note When passed a block it yields to each document.
        #
        # @example Get the in memory docs.
        #   enumerable.in_memory
        #
        # @return [ Array<Document> ] The in memory docs.
        #
        # @since 2.1.0
        def in_memory
          (loaded + added).tap do |docs|
            docs.each { |doc| yield(doc) } if block_given?
          end
        end

        # Loads all the documents in the enumerable from the database.
        #
        # @example Load all the documents.
        #   enumerable.load_all!
        #
        # @return [ true ] That the enumerable is loaded.
        #
        # @since 2.1.0
        alias :load_all! :entries

        # Has the enumerable been loaded? This will be true if the criteria has
        # been executed or we manually load the entire thing.
        #
        # @example Is the enumerable loaded?
        #   enumerable.loaded?
        #
        # @return [ true, false ] If the enumerable has been loaded.
        #
        # @since 2.1.0
        def loaded?
          !!@executed
        end

        # Reset the enumerable back to it's persisted state.
        #
        # @example Reset the enumerable.
        #   enumerable.reset
        #
        # @return [ false ] Always false.
        #
        # @since 2.1.0
        def reset
          loaded.clear and added.clear
          @executed = false
        end

        # Gets the total size of this enumerable. This is a combination of all
        # the persisted and unpersisted documents.
        #
        # @example Get the size.
        #   enumerable.size
        #
        # @return [ Integer ] The size of the enumerable.
        #
        # @since 2.1.0
        def size
          (loaded? ? loaded.count : unloaded.count) + added.count{ |d| d.new? }
        end
        alias :length :size
      end
    end
  end
end
