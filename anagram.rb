# encoding: UTF-8
# autoload :YAML, "yaml"
require "yaml"

class Anagram
  attr_reader :words
  def initialize(file)
    @words = Anagram.build_wordlist(file)
    @anagrams = Anagram.build_anagram(@words)
  end

  def find(word)
    list = @anagrams[Anagram.signize(word.downcase)]
    list ? list - [word] : []
  end

  def self.build_wordlist(file)
    file.map { |word| word.chomp.downcase }.uniq
  end

  def self.build_anagram(words)
    words.map { |word| [signize(word), word] }
         .inject({}) { |h, (sign,word)| h[sign] ||= []; h[sign] << word; h }
         .select { |sign, words| words.size > 1 }
  end

  def self.signize(word)
    word.chars.sort.join.intern
  end

  def self.build(file)
    words = build_wordlist(file)
    save(build_anagram words)
  end

  def self.save(anagrams)
    path = File.expand_path(File.dirname __FILE__) + '/anagram.yml'
    raise Errno::EEXIST, "Yaml file exist at #{path}" if File.exist?(path)
    File.open(path, 'w') { |f| YAML.dump anagrams, f }
  end
end
