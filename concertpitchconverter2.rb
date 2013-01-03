#this program will convert concert-pitch tabs to Bb-instrument tabs
@notes = {'Ab' => 'Bb','A' => 'B','Bb' => 'C','B' => 'Db','C' => 'D','Db' => 'Eb',
          'D' => 'E','Eb' => 'F','E' => 'Gb','F' => 'G','Gb' => 'Ab','G' => 'A',
          'G#' => 'Bb','A#' => 'C','C#' => 'Eb','D#' => 'F','F#' => 'Ab'}

#@acceptable = [' ','.','-',',','_','/','\\','#','b','A','B','C','D','E','F','G',"\t"]

def convert_line astring
  #find the part of the string that is usable (if any) and convert it
  #print everything
  line_re = /([^a-zH-Z][A-G.#b_\\\/-]+[A-G]+[A-G.#b_\\\/-]+)?(.{0,})/
  m = line_re.match(astring)
  print "#{convert_digits(m[1])}#{m[2]}"
end

def convert_digits astring
  note_re = /[A-G][#b]{0,1}/ #could also be /[A-G][#b]?/
  astring.gsub!(note_re) {|note| @notes[note]} if !astring.nil?
end

def convert_file filename
  file = File.new(filename, "r")
  while (line = file.gets)
    convert_line line.chomp
    print "\n"
  end
  file.close
end

if __FILE__ == $0
  #convert_line 'ECBbG <-- text!'
  convert_file "OGAwFC_brass.txt"
end



# regexp to find notes /([^a-zH-Z][A-G.#b_\\\/-]+[A-G]+[A-G.#b_\\\/-]+)/

# /([^a-zH-Z][A-G.#b_\\\/-]+[A-G]+[A-G.#b_\\\/-]+)?(.{0,})/
#        to match the whole line and separate it out

# [A-G][#b]{0,} <-- selects notes out of a string (greedy)