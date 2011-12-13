require "graphaz"
require_relative "anagram"

mosts = Anagram.new.most(:size => 100, :sign => true)
ga = GraphAz.new("Anagram", :use => "neato", :resolution => 100)
ga.gnode[:shape] = "circle"

mosts.each do |sign, words|
  words.each { |word| ga.add "#{sign} => #{word}" }
end

C = [[:darkgreen, :green], [:blue, :skyblue], [:red, :lightpink], [:darkviolet, :magenta], [:yellow, :palegoldenrod]]

mosts.each_with_index do |(sign, words), i|
  i = i % C.size
  ga.node("#{sign}", :shape => 'doublecircle', :style => 'filled', :fillcolor => C[i][0])
  words.each { |word| ga.node(word, :style => 'filled', :fillcolor => C[i][1]) }
end

ga.print_graph(:png => "anagram.png")
# ga.print_graph(:dot => "anagram.dot")
