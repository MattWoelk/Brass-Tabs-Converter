#this program will convert concert-pitch tabs to Bb-instrument tabs
@concert = ['Ab','A','Bb','B','C','Db','D','Eb','E','F','Gb','G']
@concert2 = ['G#','A','A#','B','C','C#','D','D#','E','F','F#','G']
@trumpet = ['Bb','B','C','Db','D','Eb','E','F','Gb','G','Ab','A']
@acceptable = [' ','.','-',',','_','/','\\','#','b','A','B','C','D','E','F','G',"\t"]
#@concert = ['bA','A','bB','B','C','bD','D','bE','E','F','bG','G']
#@concert2 = ['#G','A','#A','B','C','#C','D','#D','E','F','#F','G']
#@trumpet = ['bB','B','C','bD','D','bE','E','F','bG','G','bA','A']


def changed_pitch astring
  astring = astring.dup
  astring.reverse!
  #input must be reversed string (we assume that ABC..DEF__GH   <--this is notes)
  #check to see if the line contains letters that are not A-G
  #if this is the case, we treat part of the string after the space before the 
  #contaminating letter (or start of string if that be the case) as text (not notes)
  preserved = ""
  result = ""
  waiting_for_white = false
  waiting_for_weird = false
  
  astring.length.times do |anindex|
    #puts "waiting status: #{waiting_for_white}"
    #puts "current '#{astring[anindex,1]}'"
    if !(@acceptable.include?(astring[anindex,1]))
      #then we store up until (and including) the next white space
      waiting_for_weird = false
      waiting_for_white = true
      preserved = astring[0,anindex+1]
    elsif ((astring[anindex,1] == " ") || (astring[anindex,1] == "\t") || (anindex == astring.length - 1)) && waiting_for_white #space or end of line
      waiting_for_white = false
      #puts "waiting = false"
      preserved = astring[0,anindex+1]
   # elsif waiting_for_white
  #    preserved = astring[0,anindex+1]
    elsif !waiting_for_white && !waiting_for_weird && astring[anindex,1] != " "
      result = astring[anindex,astring.length-anindex]
      waiting_for_weird = true
      #puts "inter: " + result
    end
    
  end
  
  #print "\npreserved part: '#{preserved.reverse}'\n"
  #puts "usable part: '#{result}'\n"
  print convert(result.reverse).reverse.to_s + preserved.reverse
end

def convert_two_digits astring
  astring = astring.dup
  if (astring.length == 2) && (@concert.include? astring[0,2])
    #puts "#{astring[0,2]} is in the set1 (2)"
    #puts "return @trumpet[@concert.index(astring[0,2])]: #{@trumpet[@concert.index(astring[0,2])]}"
    return @trumpet[@concert.index(astring[0,2])]
  elsif (astring.length == 2) && (@concert2.include? astring[0,2])
    #puts "#{astring[0,2]} is in the set2 (2)"
    #puts "return @trumpet[@concert2.index(astring[0,2])]: #{@trumpet[@concert2.index(astring[0,2])]}"
    return @trumpet[@concert2.index(astring[0,2])]
  elsif @concert.include? astring[0,1]
    #puts "#{astring[0,1]} is in the set1 (1)"
    #puts "return @trumpet[@concert.index(astring[0,1])]: #{@trumpet[@concert.index(astring[0,1])]}"
    return @trumpet[@concert.index(astring[0,1])]
  elsif @concert2.include? astring[0,1]
    #puts "#{astring[0,1]} is in set2 (1)"
    #puts "return @concert2.index(astring[0,1]): #{@trumpet[@concert2.index(astring[0,1])]}"
    return @trumpet[@concert2.index(astring[0,1])]
  else
    #puts "#{astring[0,1]} is not there"
    if astring[0,1] != '#' && astring[0,1] != 'b' 
      #puts "return astring[0,1]: #{astring[0,1]}"
      return astring[0,1]
    else
      return ""
    end
  end
  
end
=begin
def convert astring
  astring = astring.dup
  astring.reverse!
  
  def convert astring
  #astring.dup.reverse!
  #puts "astringlength: #{astring.length}"
=end
def convert astring
  #puts "astring #{astring}"
  astring = astring.dup
  astring#.reverse!
  result = ""
  #puts "astring #{astring}"
  #puts "astring[0,2] #{astring[0,2]}"
  #puts "astring[1,2] #{astring[1,2]}"
  (0..(astring.length - 1)).each do |anindex|
    #puts "anindex: #{anindex}"
    if anindex < astring.length-1
      result = convert_two_digits(astring[anindex,2]).reverse + result 
     # puts "returning #{convert_two_digits(astring[anindex,2])} + #{result}" if anindex < astring.length-1
    else
      result = convert_two_digits(astring[anindex,1]).reverse + result
     # puts "returning #{convert_two_digits(astring[anindex,1])} + #{result}" if anindex = astring.length-1
    end
  end
  return result#.reverse
end

def convert_from_file filename
  file = File.new(filename, "r")
  while (line = file.gets)
    changed_pitch line.chomp#.reverse
    print "\n"
  end
  file.close
end

if __FILE__ == $0
  #we need to reverse the whole line, and then work with it
  #that will make things much simpler
 # puts convert_two_digits('#F').reverse
 
  #changed_pitch("..EDE.EDE.EDEFEDE.EDEFEDC___B___  <-- lower".reverse)
  
  convert_from_file 'Happy_brass.txt'
  #changed_pitch('..EEGE.F#.DEBDBb'.reverse)
  puts
  #changed_pitch('D#').reverse
  puts
  #puts convert_two_digits('D#'.reverse)
  
  #puts (convert '..EbEGE.F#.DEBDB..').reverse
end















