require "rspec"
require "./anagram"

describe Anagram, 'as instance' do
  before(:all) do
    @dic = File.open('./sample_dic')
    @anagram = Anagram.new(@dic)
    @yaml_path = File.expand_path(File.dirname __FILE__) + '/anagram.yml'
  end

  after(:all) do
    @dic.close
  end

  it "should build word list from a file" do
    @anagram.instance_variable_get('@words').take(5).should == %w(street sweet tester retest word)
  end

  it "should not contain empty or one letter words in word list" do
    words = @anagram.instance_variable_get('@words')
    refine_words = words.reject { |word| word.size < 2 }
    refine_words.size.should == words.size
  end

  it "should find anagrams with some words" do
    dic = {'street' => %w(tester tester retest), 'tower' => %w(rowet wrote)}
    dic.each { |sign, words| (@anagram.find(sign) - words).empty? }
  end

  it "should not find anagrams with some words" do
    words = %w(world hello sweet streets)
    words.each { |word| @anagram.find(word).empty? }
  end

  it "should use yaml file at instantiate without arguments" do
    if File.exist?(@yaml_path)
      anagram = Anagram.new
      dic = {'street' => %w(tester retest setter), 'tower' => %w(rowet wrote)}
      dic.each { |sign, words| (anagram.find(sign) - words).empty? }
    else
      ->{ Anagram.new }.should raise_error(Errno::ENOENT)
    end
  end

  it "should find the longest anagrams" do
    expects = [%w(monopersulphuric permonosulphuric), %w(possessioner repossession),
               %w(restraighten straightener), %w(collectioner recollection)]
    (@anagram.longest_anagrams(4) - expects).empty?
  end

  it "should find the most anagrams from one" do
    most = %w(resiant asterin eranist restain stainer starnie stearin)
    @anagram.most_anagrams.sort.should == most.sort
  end

  it "should find all anagrams" do
    @anagram.all_anagrams.size.should == 7
  end
end

describe Anagram, 'as class' do
  it "should save anagrams to a yaml file" do
    dic = File.open('./sample_dic')
    yaml_path = File.expand_path(File.dirname __FILE__) + '/anagram.yml'
    if File.exist?(yaml_path)
      ->{ Anagram.build(dic) }.should raise_error(Errno::EEXIST)
    else
      file = Anagram.build(dic)
      file.path.should == yaml_path
    end
    dic.close
  end

  it "should find anagrams with some words" do
    anagram = Anagram.new(open './sample_dic')
    dic = {'street' => %w(tester tester retest), 'tower' => %w(rowet wrote)}
    dic.each { |sign, words| (anagram.find(sign) - words).empty? }
  end
end
