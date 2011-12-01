require "rspec"
require "./anagram"

# require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Anagram do
  it "should build word list from a file" do
    dic = File.open('./sample_dic')
    anagram = Anagram.new(dic)
    anagram.dic.take(5).should == %w(street sweet tester retest word)
  end

  it "should find anagrams with word 'street'" do
    dic = File.open('./sample_dic')
    anagram = Anagram.new(dic)
    anagram.find('street').should == ['tester', 'retest']
  end

  it "should find anagrams with word 'power'" do
    dic = File.open('./sample_dic')
    anagram = Anagram.new(dic)
    anagram.find('tower').should == ['rowet', 'wrote']
  end
end
