class Anagram
  attr_reader :dic
  def initialize(file)
    @dic = file.map { |word| word.chomp.downcase }.uniq
    @anagrams = build_anagram(@dic)
  end

  def find(word)
    list = @anagrams[signize(word.downcase)]
    list ? list - [word] : list
  end

  def build_anagram(words)
    words.map { |word| [signize(word), word] }
         .inject({}) { |h, (sign,word)| h[sign] ||= []; h[sign] << word; h }
         .select { |sign, words| words.size > 1 }
  end

  def signize(word)
    word.chars.sort.join.intern
  end
end
