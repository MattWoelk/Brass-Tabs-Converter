#this program will convert concert-pitch tabs to Bb-instrument tabs
#version 4: does as many harmonies at the same time as you need
#C <-- key eighth = 0.12
#  ^-- will change the eighth length if this notation is used (or similar)

#the next version should be able to play any key in the right pitch

require 'midi_sounds.rb'

@lines= []

@eighth_length = 0.12 #the default eighth note length (pretty quick)

@threads = []  #Threads that all call "play_line"

@key = 0

#@notes is never used
@notes = {'Ab' => 'Bb','A' => 'B','Bb' => 'C','B' => 'Db','C' => 'D','Db' => 'Eb',
          'D' => 'E','Eb' => 'F','E' => 'Gb','F' => 'G','Gb' => 'Ab','G' => 'A',
          'G#' => 'Bb','A#' => 'C','C#' => 'Eb','D#' => 'F','F#' => 'Ab'}

#@pitches is never used
@pitches = ['C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B']

@pitch_n = {'C'=>0,'C#'=>1,'Db'=>1,'D'=>2,'D#'=>3,'Eb'=>3,'E'=>4,'F'=>5,'F#'=>6,'Gb'=>6,'G'=>7,'G#'=>8,'Ab'=>8,'A'=>9,'A#'=>10,'Bb'=>10,'B'=>11}

#Each of the 16 MIDI channels belongs to an instrument. The velocity represents how 
#hard a note has been pressed or released and is expressed between 0 and 127. 
#The note number identifies a specific note and is also expressed between 0 and 127.



def play_line(astring)
  if(!astring.nil?)
  midi = LiveMIDI.new
  arr = astring.scan(/[A-G][#b]{0,}[\._\/]{0,}/)
  arr1 = astring.scan(/^[\.]{0,}/) if !astring.scan(/^[\.]{0,}/).nil?
  previous_pitch = 60   #SET THIS BACK TO 60!!!
  
  n_time = 0
  r_time = 0
  pitch = 0
  
  n_times = 0
  r_times = 0
  
  print"\n"
  
  if !arr1.nil?
    arr1[0][/\.{0,}/].length.times do 
      sleep(@eighth_length)
      puts "."
    end
  end
  
  arr.length.times do |note|
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
    if /_/.match(arr[note]) 
      n_times = (arr[note][/[_\/\\]+/].length + 1)
    elsif /[A-G]/.match(arr[note])
      n_times = 1
    else
      n_times = 0
    end
    r_times = /\./.match(arr[note]) ? arr[note][/\.+/].length : 0
    
    midi.note_on(6, pitch - @key, 100)
    n_times.times do
      puts arr[note][/[A-G][b#]{0,}/]
      sleep(@eighth_length)
    end
    midi.note_off(6, pitch - @key, 100)
    r_times.times do
      puts "_"
      sleep(@eighth_length)
    end
    
  end
end
end

def convert_line astring
  #if both lines are playable, play them together, if not, play previous (if previous is playable)
  @lines.each do |lin|
    print "'#{lin}'"
  end
  print "\nlength: #{@lines.length}\n"
  line_re = /([^a-zH-Z][A-G.#b_\\\/-]+[A-G]+[A-G.#b_\\\/-]+)?(.{0,})/
  m = line_re.match(astring)
  
  if m[1]
    @lines << m[1]
  else
    if @lines.length != 0
      @lines.length.times do |t|
        @threads << Thread.new do
          play_line(@lines[t])
        end
      end
    end
    @lines = []
  end
  
  @threads.each do |thd|
    thd.join
  end
  
end

#this is never read
def convert_digits astring
  note_re = /[A-G][#b]{0,1}/ #could also be /[A-G][#b]?/
  astring.gsub!(note_re) {|note| @notes[note]} if !astring.nil?
end

def convert_file filename
  file = File.new(filename, "r")
  line = file.gets
  if /^[A-G][#b]{0,}/.match(line)   #this catches not lines that start with a note <--bad (though rare)
    @key = 12 - @pitch_n[line[/^[A-G][#b]{0,}/]]
    @eighth_length = line[/0\.[0-9]{1,}\s{0,}$/].to_f if !line[/0\.[0-9]{1,}\s{0,}$/].nil? #/.{1,}([0..9]{1,}\.[0..9]{1,})/
  else
    convert_line line.chomp
    print "\n"
  end
  while (line = file.gets)
    convert_line line.chomp
    print "\n"
  end
  file.close
  convert_line "A"  #this is to fix a bug where it doesn't play the last line of notes
  
  @threads.each do |thd|
    thd.join
  end
end

def play_riff data
  count = 0
  input = data.split(/\n/)
  puts "here"
  line = input[count]
  count +=1
  if /^[A-G][#b]{0,}/.match(line)   #this catches not lines that start with a note <--bad (though rare)
    @key = 12 - @pitch_n[line[/^[A-G][#b]{0,}/]]
    @eighth_length = line[/0\.[0-9]{1,}\s{0,}$/].to_f if !line[/0\.[0-9]{1,}\s{0,}$/].nil? #/.{1,}([0..9]{1,}\.[0..9]{1,})/
  else
    convert_line line.chomp
    print "\n"
  end
  line = input[count]
  count +=1
  while (!line.nil?)
    convert_line line.chomp
    print "\n"
    line = input[count]
    count +=1
  end
  
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
=begin play_riff <<PLAY_THIS
C <-- key eighth = 0.23

C <-- key eighth = 0.23
(put B instead of C to make this true to the song in pitch)
AA______A_______

A_______A_______F_______________
EE......DD......CC..............
CC......CC......EE..............

A_______G_______E_______B_______
EE......DD......CC......D___....
CC......CC......AA......F___....

A_______A_______F_______________
EE......DD......CC..............
CC......CC......EE..............

A_______G_______E_______B_______
EE......DD......CC......D___....
CC......CC......AA......F___....

A_______A_______A_______A.......

(verse 1)

AA______AA______AA______AA______

GG______E___G___AA______________
G_______E___G__A________________
D_______B___D__C________________

AA______AA______AA______AA______

GG______E___G___AA______________
G_______E___G__A________________
D_______B___D__C________________






















PLAY_THIS
=end
  convert_file "songs/Kamikaze_C.txt"
  #play_line("..GbGbBD.Db...E...D...Gb...EGb.E.Db.D....BD.Db...A...B...............", 0.12)
end






