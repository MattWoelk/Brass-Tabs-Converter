#this program will convert concert-pitch tabs to Bb-instrument tabs
#version 4: asks you what key you want to convert to
# =>        (fully compatible with convert_and_play2)

@key_to = 0
@key_from = 0
@key_d = 0 #the displacement necessary to convert it.

@notes = {'Ab' => 'Bb','A' => 'B','Bb' => 'C','B' => 'Db','C' => 'D','Db' => 'Eb',
          'D' => 'E','Eb' => 'F','E' => 'Gb','F' => 'G','Gb' => 'Ab','G' => 'A',
          'G#' => 'Bb','A#' => 'C','C#' => 'Eb','D#' => 'F','F#' => 'Ab'}
          
@n_1 = ['A','A#','B','C','C#','D','D#','E','F','F#','G','G#']
@n_2 = ['A','Bb','B','C','Db','D','Eb','E','F','Gb','G','Ab']

#@conv = [-3,-2,-1,0,1,2,3,4,5,6,7,8]

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
  if !astring.nil?
    astring.gsub!(note_re) do |note|   
      if !astring.nil?
        if @n_1.include?(note)
          @n_2[(@n_1.index(note) - @key_d) % 12]
        else
          @n_2[(@n_2.index(note) - @key_d) % 12]   #±
        end
      end
    end
  end
end

def convert_file filename
  print "#{@n_2[@key_to]} <-- key\n"
  file = File.new(filename, "r")
  line = file.gets
  if /^[A-G][#b]{0,}/.match(line)
    if @n_1.include?(line[/^[A-G][#b]{0,}/])
      @key_from = @n_1.index(line[/^[A-G][#b]{0,}/])
    else
      @key_from = @n_2.index(line[/^[A-G][#b]{0,}/])
    end
  else
    convert_line line.chomp
    print "\n"
  end
  @key_d = @key_to - @key_from
  puts "@key_from: #{@key_from}"
  puts "@key_to: #{@key_to}"
  puts "@key_d: #{@key_d}"
  while (line = file.gets)
    convert_line line.chomp
    print "\n"
  end
  file.close
end

if __FILE__ == $0
  #convert_line 'ECBbG <-- text!'
  puts "What key would you like this file to be converted to?"
  var = gets.chomp.scan(/^[A-G][#b]{0,1}/)[0]
  if @n_1.include?(var)
    @key_to = @n_1.index(var)
  else
    @key_to = @n_2.index(var)
  end
  #@key_to = gets.chomp.scan(/^[A-G][#b]{0,1}/)[0]
  convert_file "OGAwFC_trumpet.txt"
end



# regexp to find notes /([^a-zH-Z][A-G.#b_\\\/-]+[A-G]+[A-G.#b_\\\/-]+)/

# /([^a-zH-Z][A-G.#b_\\\/-]+[A-G]+[A-G.#b_\\\/-]+)?(.{0,})/
#        to match the whole line and separate it out

# [A-G][#b]{0,} <-- selects notes out of a string (greedy)