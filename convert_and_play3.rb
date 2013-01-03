#this program will convert concert-pitch tabs to Bb-instrument tabs
#version 3: IT DOES HARMONIES!!! YES!!

#to do infinity-part harmonies, just have an array instead of @previous_line
#  and clear and play it whenever the incoming string is non-notes

require 'midi_sounds.rb'

@by = false  #true if we want to skip the next line (so that we don't play the second of a duo twice)

@previous_line = "booger"

@threads = []  #Threads that all call "play_line"

@key = 0

@notes = {'Ab' => 'Bb','A' => 'B','Bb' => 'C','B' => 'Db','C' => 'D','Db' => 'Eb',
          'D' => 'E','Eb' => 'F','E' => 'Gb','F' => 'G','Gb' => 'Ab','G' => 'A',
          'G#' => 'Bb','A#' => 'C','C#' => 'Eb','D#' => 'F','F#' => 'Ab'}
@pitches = ['C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B']

@pitch_n = {'C'=>0,'C#'=>1,'Db'=>1,'D'=>2,'D#'=>3,'Eb'=>3,'E'=>4,'F'=>5,'F#'=>6,'Gb'=>6,'G'=>7,'G#'=>8,'Ab'=>8,'A'=>9,'A#'=>10,'Bb'=>10,'B'=>11}

#@acceptable = [' ','.','-',',','_','/','\\','#','b','A','B','C','D','E','F','G',"\t"]
#Each of the 16 MIDI channels belongs to an instrument. The velocity represents how 
#hard a note has been pressed or released and is expressed between 0 and 127. 
#The note number identifies a specific note and is also expressed between 0 and 127.



def play_line(astring, eighth_length)
  if(!astring.nil?)
  midi = LiveMIDI.new
  arr = astring.scan(/[A-G][#b]{0,}[\._\/]{0,}/)
  arr1 = astring.scan(/^[\.]{0,}/) if !astring.scan(/^[\.]{0,}/).nil?
  previous_pitch = 60   #SET THIS BACK TO 60!!!
  
  #puts arr1[0]
  n_time = 0
  r_time = 0
  pitch = 0
  
  n_times = 0
  r_times = 0
  
  #puts astring
  print"\n"
  #do the beginning rest (this isn't the best way to do this, but it works
  if !arr1.nil?
    arr1[0][/\.{0,}/].length.times do 
      sleep(eighth_length)
      puts "."
    end
  end
  #sleep(arr1[0][/\.+/].length * eighth_length) if !arr1[0].nil?
  
  arr.length.times do |note|
    #puts "LOOK HERE: #{}"
    #pitch = 60 + @pitches.index(arr[note][/[A-G][b#]{0,}/])
    difference = @pitch_n[arr[note][/[A-G][b#]{0,}/]] - (previous_pitch % 12)
    
    if difference >= 8
      pitch = previous_pitch - (12 - difference)
    elsif difference > 0
      pitch = previous_pitch + difference
    elsif difference <= -8
      pitch = previous_pitch + (12 + difference)
    else
      pitch = previous_pitch + difference
    end
    previous_pitch = pitch
    #puts "pitch #{pitch}"
    if /_/.match(arr[note]) 
      #n_time = (arr[note][/[_\/\\]+/].length + 1) * eighth_length 
      n_times = (arr[note][/[_\/\\]+/].length + 1)
    elsif /[A-G]/.match(arr[note])
      #n_time = eighth_length
      n_times = 1
    else
      #n_time = 0
      n_times = 0
    end
    #puts "n_time #{n_time}"
    #r_time = /\./.match(arr[note]) ? arr[note][/\.+/].length * eighth_length : 0
    r_times = /\./.match(arr[note]) ? arr[note][/\.+/].length : 0
    
    #midi.note_on(0, pitch, 100)
    #sleep(n_time)
    #midi.note_off(0, pitch, 100)
    #sleep(r_time)
    
    midi.note_on(6, pitch - @key, 100)     #CHANGE THIS BACK
    n_times.times do
      puts arr[note][/[A-G][b#]{0,}/]
      sleep(eighth_length)
    end
    midi.note_off(6, pitch - @key, 100)    #CHANGE THIS BACK
    r_times.times do
      puts "_"
      sleep(eighth_length)
    end
    
  end
end
end

def convert_line astring
  #if both lines are playable, play them together, if not, play previous (if previous is playable)
  if (!@previous_line.nil? && (@previous_line <=> "booger") == 0) || @by
    line_re = /([^a-zH-Z][A-G.#b_\\\/-]+[A-G]+[A-G.#b_\\\/-]+)?(.{0,})/
    m = line_re.match(astring)
    @previous_line = m[1]
    #puts "m[1] #{m[1]}"
    #puts "previous line is 'booger' OR @by"
    @by = false
    return
  end
  line_re = /([^a-zH-Z][A-G.#b_\\\/-]+[A-G]+[A-G.#b_\\\/-]+)?(.{0,})/
  m = line_re.match(astring)
  
  if !@previous_line.nil? && @previous_line != "" && !m[1].nil? && m[1] != ""
    @threads << Thread.new do
      play_line(@previous_line,0.12)
    end
    @threads << Thread.new do
      play_line(m[1],0.12)
    end
    @by = true
  elsif !@previous_line.nil? && @previous_line != ""
    @threads << Thread.new do
      play_line(@previous_line,0.12)
    end
  end
  
  @previous_line = m[1]
  
  @threads.each do |thd|
    thd.join
  end
  
  #print "#{convert_digits(m[1])}#{m[2]}"
end

def convert_digits astring
  note_re = /[A-G][#b]{0,1}/ #could also be /[A-G][#b]?/
  astring.gsub!(note_re) {|note| @notes[note]} if !astring.nil?
end

def convert_file filename
  file = File.new(filename, "r")
  line = file.gets
  if /^[A-G][#b]{0,}/.match(line)   #this catches not lines that start with a note <--bad (though rare)
    @key = 12 - @pitch_n[line[/^[A-G][#b]{0,}/]]
  else
    convert_line line.chomp
    print "\n"
  end
  while (line = file.gets)
    convert_line line.chomp
    #play_line(line.chomp, 0.1)
    print "\n"
  end
  file.close
  convert_line "A"  #this is to fix a bug where it doesn't play the last line of notes
  
  @threads.each do |thd|
    thd.join
  end
end

def keyboard_mode(num)
  while true
    temp = gets
    play_line(temp, num)
  end
end

if __FILE__ == $0
  #convert_line 'ECBbG <-- text!'
  #keyboard_mode(0.12)
  
  convert_file "songs/wilderness_brass.txt"
  #play_line("..GbGbBD.Db...E...D...Gb...EGb.E.Db.D....BD.Db...A...B...............", 0.12)
end



# regexp to find notes /([^a-zH-Z][A-G.#b_\\\/-]+[A-G]+[A-G.#b_\\\/-]+)/

# /([^a-zH-Z][A-G.#b_\\\/-]+[A-G]+[A-G.#b_\\\/-]+)?(.{0,})/
#        to match the whole line and separate it out

# [A-G][#b]{0,} <-- selects notes out of a string (greedy)