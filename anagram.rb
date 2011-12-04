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
    list = @anagrams[Anagram.signature(word)]
    list ? list - [word] : []
  end

  def all
    @anagrams.values
  end

  def longest(size=1)
    portion_anagrams(size) { |sign, words| -sign.size }
  end

  def most(size=1)
    portion_anagrams(size) { |sign, words| -words.size }
  end

  private
  def portion_anagrams(size)
    res = @anagrams.sort_by { |sign, words| yield(sign, words) }.take(size).map(&:last)
    size==1 ? res.flatten : res
  end

  class << self
    def find(word)
      self.new.find(word)
    end

    def anagrams?(*words)
      raise ArgumentError, "at least 2 arguments" unless words.size > 1
      signs = words.map { |word| signature word }
      raise ArgumentError, "word must consist of 2 or more chars" unless signs.all?{ |w| w.size > 1 }
      signs.uniq.size == 1
    end
    
    def build_wordlist(file)
      file.map { |word| word.chomp.downcase }.uniq.reject { |word| word.size < 2 }
    end

    def build_anagram(words)
      words.map { |word| [signature(word), word] }
           .inject({}) { |h, (sign,word)| h[sign] ||= []; h[sign] << word; h }
    end

    def signature(word)
      word.downcase.scan(/\p{Alnum}/).sort.join.intern
    end

    def build(file)
      file_exist_error(PATH)
      words = build_wordlist(file)
      anagrams = build_anagram(words)
      save(anagrams)
    end

    PATH = File.expand_path(File.dirname __FILE__) + '/anagram.yml'
    def save(anagrams)
      file_exist_error(PATH)
      File.open(PATH, 'w') { |f| YAML.dump anagrams, f }
    end

    def load_anagram
      YAML.load_file(PATH)
    end
    
    def file_exist_error(path)
      raise Errno::EEXIST, "Yaml file exist at #{path}" if File.exist?(path)
    end
  end
end
