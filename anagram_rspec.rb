require "rspec"
require "./anagram"

# require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Anagram do
  before do
    dic = File.open('./sample_dic')
    @anagram = Anagram.new(dic)
    dic.close
  end

  it "should build word list from a file" do
    @anagram.words.take(5).should == %w(street sweet tester retest word)
  end

  it "should find anagrams with some words" do
    dic = {'street' => %w(tester retest), 'tower' => %w(rowet wrote)}
    dic.each { |sign, words| @anagram.find(sign).should == words }
  end

  it "should not find anagrams with some words" do
    words = %w(world hello sweet streets)
    words.each { |word| @anagram.find(word).should == [] }
  end

  it "should save anagrams to a yaml file" do
    dic = File.open('./sample_dic')
    yaml_path = File.expand_path(File.dirname __FILE__) + '/anagram.yml'
    if File.exist?(yaml_path)
      ->{ Anagram.build(dic) }.should raise_error(Errno::EEXIST)
    else
      file = Anagram.build(dic)
      file.path.should == yaml_path
    end
  end
end
