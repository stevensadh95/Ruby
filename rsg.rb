# Extracts just the definitions from the grammar file
# Returns an array of strings where each string is the lines for
# a given definition (without the braces)
def read_grammar_defs(filename)
  filename = 'grammars/' + filename unless filename.start_with? 'grammars/'
  filename += '.g' unless filename.end_with? '.g'
  contents = open(filename, 'r') { |f| f.read }
  contents.scan(/\{(.+?)\}/m).map do |rule_array|
    rule_array[0]
  end
end

# Takes data as returned by read_grammar_defs and reformats it
# in the form of an array with the first element being the
# non-terminal and the other elements being the productions for
# that non-terminal.
# Remember that a production can be empty (see third example)
# Example:
#   split_definition "\n<start>\nYou <adj> <name> . ;\nMay <curse> . ;\n"
#     returns ["<start>", "You <adj> <name> .", "May <curse> ."]
#   split_definition "\n<start>\nYou <adj> <name> . ;\n;\n"
#     returns ["<start>", "You <adj> <name> .", ""]
def split_definition(raw_def)

  # removes extra newlines
  tokens = raw_def.strip.split("\n")
  tokens2 = tokens.map {|element| element.delete(";").strip}
end

# Takes an array of definitions where the definitions have been
# processed by split_definition and returns a Hash that
# is the grammar where the key values are the non-terminals
# for a rule and the values are arrays of arrays containing
# the productions (each production is a separate sub-array)

# Example:
# to_grammar_hash([["<start>", "The   <object>   <verb>   tonight."], ["<object>", "waves", "big    yellow       flowers", "slugs"], ["<verb>", "sigh <adverb>", "portend like <object>", "die <adverb>"], ["<adverb>", "warily", "grumpily"]])
# returns {"<start>"=>[["The", "<object>", "<verb>", "tonight."]], "<object>"=>[["waves"], ["big", "yellow", "flowers"], ["slugs"]], "<verb>"=>[["sigh", "<adverb>"], ["portend", "like", "<object>"], ["die", "<adverb>"]], "<adverb>"=>[["warily"], ["grumpily"]]}
def to_grammar_hash(split_def_array)
  # element[0] of a definition  is the key.
  hash = {}
  # temp_array = split_def_array
  # key = temp_array[0]
  # temp_array.delete(temp_array.index(0))
  for definition in split_def_array
    key = definition[0]
    definition.delete_at(0)
    array = []
    for element in definition
      array.push(element.split(" "))
    end
   hash[key] = array
  end

hash
end

# Returns true iff s is a non-terminal
# a.k.a. a string where the first character is <
#        and the last character is >
def is_non_terminal?(s)
   (s[0] == "<" and s[s.length-1] == ">")

end

# Given a grammar hash (as returned by to_grammar_hash)
# returns a string that is a randomly generated sentence from
# that grammar
#
# Once the grammar is loaded up, begin with the <start> production and expand it to generate a
# random sentence.
# Note that the algorithm to traverse the data structure and
# return the terminals is extremely recursive.
#
# The grammar will always contain a <start> non-terminal to begin the
# expansion. It will not necessarily be the first definition in the file,
# but it will always be defined eventually. Your code can
# assume that the grammar files are syntactically correct
# (i.e. have a start definition, have the correct  punctuation and format
# as described above, don't have some sort of endless recursive cycle in the
# expansion, etc.). The names of non-terminals should be considered
# case-insensitively, <NOUN> matches <Noun> and <noun>, for example.
def expand(grammar, non_term="<start>")
  sentence = ""

  if non_term.kind_of? Array
  for item in non_term
     sentence += expand(grammar, item)
  end
    return sentence
  end

  if not is_non_terminal? non_term
      return " " + non_term


  elsif non_term == "<start>"
    list = grammar[non_term]
    list2 = list[0]

      for item in list2
      sentence += expand(grammar, item)
      end

    return sentence

  else
    list = grammar[non_term]
      len = list.length
      rand_item_index = rand(len)
      return expand(grammar,list[rand_item_index])

    end
  end


# Given the name of a grammar file,
# read the grammar file and print a
# random expansion of the grammar
def rsg(filename)
  grammar = []
  definition = read_grammar_defs filename
  for line in definition
  grammar.push(split_definition(line))
  end
  hash = to_grammar_hash(grammar)
  print(expand(hash))
end

if __FILE__ == $0
  print("Please Enter the name of the file to be read\n")
  input = gets.strip
  rsg(input)
end


