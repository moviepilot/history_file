require 'spec_helper'
require 'date'

describe HistoryFile::FileDelegator do

  let(:fd){ HistoryFile::FileDelegator.new("some_prefix") }

  context "prefixing the filename" do
    after(:all) do
      File.unlink("some_prefix-rspec_tmp_test.txt") rescue nil
    end

    it "delegates generic methods to File directly" do
      File.should_receive(:split).with("/some/path")
      fd.split("/some/path")
    end

    it "delegates bulk methods with all parameters prefixed" do
      offset = Date.parse("1983-04-03")
      File.should_receive(:unlink).with("./1983.04.03-file1", "./1983.04.03-file2")
      HistoryFile[offset].unlink("file1", "file2")
    end

    it "instanciating new File instances works as expected" do
      f = fd.new("rspec_tmp_test.txt", "w")
      f.write("works")
      f.close
      File.read("some_prefix-rspec_tmp_test.txt").should == "works"
    end

    it "writing into a file using a block works as expected" do
      fd.open("rspec_tmp_test.txt", "w") do |file|
        file.write("works")
      end
      File.read("some_prefix-rspec_tmp_test.txt").should == "works"
    end
  end

  context "prefixing with sub directories" do

  end
end

describe HistoryFile do

  context "writing and reading files" do
    it "uses a correct prefix" do
      offset = Date.parse("1979-12-22")
      HistoryFile[offset].open("rspec_tmp_test.txt", "w") do |file|
        file.write("old dude")
      end
      File.read("1979.12.22-rspec_tmp_test.txt").should == "old dude"
      File.unlink("1979.12.22-rspec_tmp_test.txt")
    end

    it "doesn't allow offsets that don't respond to strftime" do
      expect{
        HistoryFile[:today].open("rspec_tmp_test.txt", "w")
      }.to raise_error(ArgumentError, "Offset today must respond to strftime")
    end
  end

  context "falling back to older files" do
    before(:all) do
      [1,2,3,6,7].each do |i|
        date = DateTime.now - i
        HistoryFile[date].open("ht.txt", "w") do |file|
          file.write "Day #{i}"
        end
      end
    end

    after(:all) do
      [1,2,3,6,7].each do |i|
        date = DateTime.now - i
        HistoryFile[date].unlink("ht.txt")
      end
    end

    it "to yesterday's file" do
      date = DateTime.now - 4
      HistoryFile[date].read("ht.txt").should == "Day 6"
    end

    it "to an error if nothing older exists" do
      expect{
        date = DateTime.now - 8
        HistoryFile[date].read("ht.txt")
      }.to raise_error(Errno::ENOENT)
    end
  end
end
