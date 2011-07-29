require "benchmark"
require "mongoid"
require "./perf/models"

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db("mongoid_perf_test")
end

Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)

puts "Creating indexes..."

[ Person, Post, Game, Preference ].each(&:create_indexes)

puts "Starting benchmark..."

Benchmark.bm do |bm|

  puts "\n[ Root Document Benchmarks ]"

  [ 1000, 10000, 100000, 1000000 ].each do |i|

    Mongoid.unit_of_work do

      puts "[ #{i} ]"

      bm.report("#create           ") do
        i.times do |n|
          Person.create(:birth_date => Date.new(1970, 1, 1))
        end
      end

      bm.report("#each             ") do
        Person.all.each { |person| person.birth_date }
      end

      bm.report("#find             ") do
        Person.find(Person.first.id)
      end

      bm.report("#save             ") do
        Person.all.each do |person|
          person.title = "Testing"
          person.save
        end
      end

      bm.report("#update_attribute ") do
        Person.all.each { |person| person.update_attribute(:title, "Updated") }
      end

      Person.delete_all
    end
  end

  GC.start

  person = Person.create(:birth_date => Date.new(1970, 1, 1))

  puts "\n[ Embedded 1-n Benchmarks ]"

  [ 1000, 10000 ].each do |i|

    Mongoid.unit_of_work do

      puts "[ #{i} ]"

      bm.report("#build            ") do
        i.times do |n|
          person.addresses.build(
            :street => "Wienerstr. #{n}",
            :city => "Berlin",
            :post_code => "10999"
          )
        end
      end

      bm.report("#clear            ") do
        person.addresses.clear
      end

      bm.report("#create           ") do
        i.times do |n|
          person.addresses.create(
            :street => "Wienerstr. #{n}",
            :city => "Berlin",
            :post_code => "10999"
          )
        end
      end

      bm.report("#count            ") do
        person.addresses.count
      end

      bm.report("#delete_all       ") do
        person.addresses.delete_all
      end

      person.addresses.clear
      GC.start

      bm.report("#push (batch)     ") do
        [].tap do |addresses|
          i.times do |n|
            addresses << Address.new(
                :street => "Wienerstr. #{n}",
                :city => "Berlin",
                :post_code => "10999"
              )
          end
          person.addresses.push(addresses)
        end
      end

      bm.report("#each             ") do
        person.addresses.each do |address|
          address
        end
      end

      address = person.addresses.last

      bm.report("#find             ") do
        person.addresses.find(address.id)
      end

      bm.report("#delete           ") do
        person.addresses.delete(address)
      end

      person.addresses.delete_all
    end
  end

  GC.start

  puts "\n[ Embedded 1-1 Benchmarks ]"

  [ 1000, 10000 ].each do |i|

    Mongoid.unit_of_work do

      puts "[ #{i} ]"

      bm.report("#relation=        ") do
        i.times do |n|
          person.name = Name.new(:given => "Name #{n}")
        end
      end
    end
  end

  GC.start

  puts "\n[ Referenced 1-n Benchmarks ]"

  [ 1000, 10000, 100000 ].each do |i|

    Mongoid.unit_of_work do

      puts "[ #{i} ]"

      bm.report("#build            ") do
        i.times do |n|
          person.posts.build(:title => "Posting #{n}")
        end
      end

      bm.report("#clear            ") do
        person.posts.clear
      end

      bm.report("#create           ") do
        i.times do |n|
          person.posts.create(:title => "Posting #{n}")
        end
      end

      bm.report("#count            ") do
        person.posts.count
      end

      bm.report("#delete_all       ") do
        person.posts.delete_all
      end

      person.posts.clear
      GC.start

      bm.report("#push (batch)     ") do
        [].tap do |posts|
          i.times do |n|
            posts << Post.new(:title => "Posting #{n}")
          end
          person.posts.push(posts)
        end
      end

      bm.report("#each             ") do
        person.posts.each do |post|
          post
        end
      end

      post = person.posts.last

      bm.report("#find             ") do
        person.posts.find(post.id)
      end

      bm.report("#delete           ") do
        person.posts.delete(post)
      end

      person.posts.clear
      GC.start
    end
  end

  puts "\n[ Referenced 1-1 Benchmarks ]"

  [ 1000, 10000, 100000 ].each do |i|

    Mongoid.unit_of_work do

      puts "[ #{i} ]"

      bm.report("#relation=        ") do
        i.times do |n|
          person.game = Game.new(:name => "Final Fantasy #{n}")
        end
      end
    end
  end

  GC.start

  puts "\n[ Referenced n-n Benchmarks ]"

  [ 1000, 10000 ].each do |i|

    Mongoid.unit_of_work do

      puts "[ #{i} ]"

      GC.disable

      bm.report("#build            ") do
        i.times do |n|
          person.preferences.build(:name => "Preference #{n}")
        end
      end

      GC.enable
      GC.start

      bm.report("#clear            ") do
        person.preferences.clear
      end

      GC.disable

      bm.report("#create           ") do
        i.times do |n|
          person.preferences.create(:name => "Preference #{n}")
        end
      end

      GC.enable
      GC.start

      bm.report("#count            ") do
        person.preferences.count
      end

      bm.report("#delete_all       ") do
        person.preferences.delete_all
      end

      person.preferences.clear
      GC.start

      bm.report("#push (batch)     ") do
        [].tap do |preferences|
          i.times do |n|
            preferences << Preference.new(:name => "Preference #{n}")
          end
          person.preferences.push(preferences)
        end
      end

      bm.report("#each             ") do
        person.preferences.each do |preference|
          preference
        end
      end

      preference = person.preferences.last

      bm.report("#find             ") do
        person.preferences.find(preference.id)
      end

      bm.report("#delete           ") do
        person.preferences.delete(preference)
      end

      person.preferences.clear
      GC.start
    end
  end
end
