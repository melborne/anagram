# encoding: UTF-8

class Anagram
  autoload :YAML, "yaml"
  def initialize(file=nil)
    @anagrams =
      if file
        @words = Anagram.build_wordlist(file)
        Anagram.build_anagram(@words)
      else
        Anagram.load_anagram
      end
  end

  def find(word)
    list = @anagrams[Anagram.signize(word.downcase)]
    list ? list - [word] : []
  end

  def longest_anagrams(size=1)
    portion_anagrams(size) { |sign, words| -sign.size }
  end

  def most_anagrams(size=1)
    portion_anagrams(size) { |sign, words| -words.size }
  end

  private
  def portion_anagrams(size)
    res = @anagrams.sort_by { |sign, words| yield(sign, words) }.take(size).map(&:last)
    size==1 ? res.flatten : res
  end

  class << self
    def build_wordlist(file)
      file.map { |word| word.chomp.downcase }.uniq.reject { |word| word.size < 2 }
    end

    def build_anagram(words)
      words.map { |word| [signize(word), word] }
           .inject({}) { |h, (sign,word)| h[sign] ||= []; h[sign] << word; h }
           .select { |sign, words| words.size > 1 }
    end

    def signize(word)
      word.chars.sort.join.intern
    end

    def build(file)
      words = build_wordlist(file)
      anagrams = build_anagram(words)
      save(anagrams)
    end

    PATH = File.expand_path(File.dirname __FILE__) + '/anagram.yml'
    def save(anagrams)
      raise Errno::EEXIST, "Yaml file exist at #{PATH}" if File.exist?(PATH)
      File.open(PATH, 'w') { |f| YAML.dump anagrams, f }
    end

    def load_anagram
      YAML.load_file(PATH)
    end
  end
end
