require 'spec_helper'
require 'date'

describe HistoryFile::FileDelegator do

  context "prefixing the filename" do
    let(:fd){ HistoryFile::FileDelegator.new(prefix: "some_prefix") }

    after(:all) do
      File.unlink("some_prefix-rspec_tmp_test.txt") rescue nil
    end

    before(:each) do
      HistoryFile.mode = :filename
    end

    it "raises an exception if a :prefix is missing" do
      expect{
        HistoryFile::FileDelegator.new({})
      }.to raise_error(ArgumentError, ":prefix needed")
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
    let(:sdfd){ HistoryFile::FileDelegator.new(prefix: "some_prefix", use_subdirs: true) }

    it "creates the right filename with a directory as a prefix" do
      sdfd.prefixed_filename('test').should == "./some_prefix/test"
    end

    it "attempts to create a directory" do
      Dir.should_receive(:mkdir).with("./some_prefix")
      File.should_receive(:open).with("./some_prefix/foo")
      sdfd.open("foo") do |io|
        io.write "don't"
      end
    end

  end
end

describe HistoryFile do

  context "writing and reading files" do
    before(:each) do
      HistoryFile.mode = :filename
    end

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

  [:subdir, :filename].each do |mode|
    HistoryFile.mode = mode
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
        Dir.unlink("some_prefix") rescue nil
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
end
