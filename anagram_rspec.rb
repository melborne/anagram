# encoding: UTF-8
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

  context "WordList" do
    it "should build a word list from a file" do
      @anagram.instance_variable_get('@words').take(5).should == %w(street sweet tester retest word)
    end

    it "should not contain empty or one letter word in the word list" do
      words = @anagram.instance_variable_get('@words')
      refine_words = words.reject { |word| word.size < 2 }
      refine_words.size.should == words.size
    end
  end

  context "Find anagram" do
    it "should find some anagrams with words 'street' and 'tower'" do
      dic = {'street' => %w(tester tester retest), 'tower' => %w(rowet wrote)}
      dic.each { |sign, words| (@anagram.find(sign) - words).empty? }
    end

    it "should not find any anagrams with words 'world', 'hello', 'sweet', 'street'" do
      words = %w(world hello sweet streets)
      words.each { |word| @anagram.find(word).empty? }
    end

    it "should use the anagram file if any at instantiation without arguments" do
      if File.exist?(@yaml_path)
        anagram = Anagram.new
        dic = {'street' => %w(tester retest setter), 'tower' => %w(rowet wrote)}
        dic.each { |sign, words| (anagram.find(sign) - words).empty? }
      end
    end    

    it "should work with Japanese words" do
      words = {'どらえもん' => ['もえらんど'], 'かとうあい' => ['あとうかい']}
      words.each { |sign, words| (@anagram.find(sign) - words).empty? }
    end
  end

  it "should be error at instantiation without arguments when a yaml file note exist" do
    unless File.exist?(@yaml_path)
      ->{ Anagram.new }.should raise_error(Errno::ENOENT)
    end
  end

  it "should find the last 4 longest anagrams" do
    expects = [%w(monopersulphuric permonosulphuric), %w(possessioner repossession),
               %w(restraighten straightener), %w(collectioner recollection)]
    (@anagram.longest_anagrams(4) - expects).empty?
  end

  it "should find the most anagrams from one" do
    most = %w(resiant asterin eranist restain stainer starnie stearin)
    @anagram.most_anagrams.sort.should == most.sort
  end

  it "should take all anagrams" do
    @anagram.all_anagrams.size.should == 9
  end
end

describe Anagram, 'as class' do
  context "build class method" do
    it "should build and save anagrams to a yaml file if it doesnt exist" do
      dic = File.open('./sample_dic')
      yaml_path = File.expand_path(File.dirname __FILE__) + '/anagram.yml'
      unless File.exist?(yaml_path)
        file = Anagram.build(dic)
        file.path.should == yaml_path
      end
      dic.close
    end

    it "should be error when building anagrams if the yaml file exist" do
      dic = File.open('./sample_dic')
      yaml_path = File.expand_path(File.dirname __FILE__) + '/anagram.yml'
      if File.exist?(yaml_path)
        ->{ Anagram.build(dic) }.should raise_error(Errno::EEXIST)
      end
      dic.close
    end    
  end

  context "find class method" do
    it "should find anagrams with words 'street', 'tower'" do
      anagram = Anagram.new(open './sample_dic')
      dic = {'street' => %w(tester setter retest), 'tower' => %w(rowet wrote)}
      dic.each { |sign, words| (anagram.find(sign) - words).empty? }
    end    
  end

  context "anagram? class method" do
    it "should be true with two anagram words" do
      dic = [%w(street tester), %w(restain stearin)]
      dic.each { |a, b| Anagram.anagrams?(a, b).should == true }
    end

    it "should be true with three or more anagram words" do
      dic = [%w(tester retest setter), %w(resiant asterin eranist restain)]
      dic.each { |words| Anagram.anagrams?(*words).should == true }
    end

    it "should be true with anagram sentences" do
      sentence1 = "To be or not to be: that is the question; whether 'tis nobler in the mind to suffer the slings and arrows of outrageous fortune..."
      sentence2 = "In one of the Bard's best-thought-of tragedies our insistent hero, Hamlet, queries on two fronts about how life turns rotten."
      Anagram.anagrams?(sentence1, sentence2).should == true
    end

    it "should be true with unicode words" do
      dic = [%w(いきるいみなんて みんないきている), %w(どらえもん もえらんど), %w(ぜいたくはてきだ てきはいただくぜ)]
      dic.each { |words| Anagram.anagrams?(*words).should == true }
    end

    it "should be false with non-anagram words" do
      dic = [%w(tester retest settor), %w(siant asterin eranist restain)]
      dic.each { |words| Anagram.anagrams?(*words).should == false }
    end

    it "should be error with zero or one word" do
      dic = [['street'], []]
      dic.each { |word| ->{ Anagram.anagrams?(*word) }.should raise_error(ArgumentError) }
    end

    it "should be error with only non-alphabetical words" do
      dic = [['%$**', '//=+'], ['__&@', '__&@']]
      dic.each { |words| ->{ Anagram.anagrams?(*words) }.should raise_error(ArgumentError) }
    end
  end
end
