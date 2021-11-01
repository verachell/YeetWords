###  YeetWords
###  a domain-specific language for text substitution, implemented in Ruby
###  Copyright (C) 2021  Veronique Chellgren
###
###    This program is free software: you can redistribute it and/or modify
###    it under the terms of the GNU General Public License as published by
###    the Free Software Foundation, either version 3 of the License, or
###    (at your option) any later version.
###
###    This program is distributed in the hope that it will be useful,
###    but WITHOUT ANY WARRANTY; without even the implied warranty of
###    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
###    GNU General Public License for more details.
###
###    You should have received a copy of the GNU General Public License
###    along with this program.  If not, see <https://www.gnu.org/licenses/>.
###
###  author: Veronique (Vera) Chellgren
###  https://github.com/verachell
###
###  usage: ruby yeetwords.rb yourcodefile.txt
###
############################################################################

require 'set'

def lexer_puts(str)
  # outputs the string to standard output, prefixed by a constant.
  # this helps the user distinguish between messages from this program's
  # lexer and parser versus fall-through messages from the ruby interpreter.
  print "Y| "
  puts str
end

def warning(severity, str, command = "", linenum = "", cominfo = "")
  if command != "" then
    str.concat(" in command #{command}")
    if linenum != "" then
      str.concat(" at line number #{linenum}")
      if cominfo != "" then
        str.concat(": #{cominfo}")
      end
    end
  end
  lexer_puts("#{severity.upcase} WARNING: #{str}")
end

def severe_warning
  self.method(:warning).curry.("SEVERE")
end

def mild_warning
  self.method(:warning).curry.("MILD")
end

def stop_with_error(str)
  lexer_puts("STOPPING: SERIOUS ERROR. #{str}")
  abort
end

def stop_with_general_command_error(desc, cmdname, linenum, comline, expected = "", actual = "")
  startstr = "#{desc} in #{cmdname} in line number #{linenum.to_s}: #{comline}"
  if expected != "" then
    finstr = "\n Expected: #{expected}"
    if actual != "" then
      finstr = finstr.concat(" . You put: #{actual}")
    end
  else
    finstr = ""
  end
  stop_with_error(startstr + finstr)
end

def stop_with_par_num_error
  self.method(:stop_with_general_command_error).curry.("Incorrect number of parameters")
end

def stop_with_unknown_variable_error(varname)
  self.method(:stop_with_general_command_error).curry.("Unknown variable name #{varname}")
end

def stop_with_syntax_error
  self.method(:stop_with_general_command_error).curry.("Incorrect syntax")
end

def stop_with_par_value_error
  self.method(:stop_with_general_command_error).curry.("Incorrect parameter value")
end

def arr_2_sentence(thearr, preceding = "")
  # takes an array with 2 or more items and returns the items as a string
  # listed in the following format: [preceding]__, [preceding]__ and [preceding]___
  result = ""
  if preceding != "" then
    result = preceding + " "
  end
  thearr.each_with_index{|x, ind|
    if ind < thearr.size - 2 then
      tempstr = ", "
      if preceding != "" then
        tempstr.concat(preceding)
      end
    elsif ind == thearr.size - 2 then
      tempstr = " and "
      if preceding != "" then
        tempstr.concat(preceding, " ")
      end
    else
      tempstr = ""
    end
    result.concat(x, tempstr)}
  return result
end

def select_random(unique, howmany, arr, exclude = [])
  # Given an array and a number of desired items designated by the howmany
  # parameter, returns an array with
  # a random selection of items from the original array.
  # In the situation where a larger number of unique items are requested
  # than exist in the queried array, a smaller array will be returned than
  # what was requested (this may be an empty array).
  #
  # This function also works with hashes as the input and will return a hash
  # BUT the hash function MUST only be called with unique = true, otherwise
  # may wind up with less results than expected from due to the conversion
  # of a non-unique array to a hash. Because of this, it emits a warning
  # if run with unique = false and arr.class = Hash
  if unique == false and arr.class == Hash then
    # WARN_ID APPLE
    severe_warning.call("This error should not come up, but if it does, please contact the programmer. When selecting random items from a catalog of items, non-uniques are specified. This does not work well with a catalog and may result in fewer items being returned than requested. The program is able to continue, however.")
  end
  if arr.class == Array then
    sourcearr = arr.clone
  else
    sourcearr = arr.clone.to_a
  end
  if exclude.class == Array then
    excluded = exclude
  else
    excluded = exclude.to_a
  end
  destarr = Array.new
  get_randoms = lambda{|source, dest, totalnum|
    if (source.size == 0) or (dest.size == totalnum)
      return dest
    else
      max_ind = source.size - 1
      r_ind = rand(0..max_ind)
      r_item = source[r_ind]
      dest << r_item
      if unique == true then
        newsource = source - [r_item]
      else
        newsource = source
      end
      dest = get_randoms.call(newsource, dest, totalnum)
    end
  }
  result =  get_randoms.call((sourcearr - excluded), destarr, howmany)
  if arr.class == Hash then
    return result.to_h
  else
    return result
  end
end

def select_random_unique
  # parameters for .call  (howmany, arr, exclude = [])
  # Variant of select_random to return only unique items -
  # see select_random for details.
  self.method(:select_random).curry.(true)
end

def select_random_one
  # parameters for .call (arr, exclude = [])
  # Variant of select_random to return only one item - see
  # select_random for details.
  self.method(:select_random).curry.(false, 1)
end

def gender_set_exists?(curr_state, str)
  # given a string and the current state, returns true if the gender
  # in the string corresponds to a set of genders, otherwise returns false.
  if curr_state["gender_info"].include?(str.strip.to_sym) then
    true
  else
    false
  end
end

def first_word(str)
  # given a string (usually a command line string), returns the first
  # word with whitespace stripped from both ends.
  # Note that it has the limitation that if there is no space, it
  # returns an empty string. It may be better rewritten to account for
  # strings which are 1 word that do not contain a space. If doing a rewrite,
  # be very careful to check functions that are calling it, as well
  # as get_command. future_work
  firstspace = str.strip.index(' ')
  if firstspace == nil then
    ""
  else
    str[0..firstspace - 1].strip
  end
end

def get_command(str)
  # given a string that contains a command, returns the name of the command.
  # Note that this function would be affected by any proposed changes
  # to the function first_word. future_work
  if first_word(str).empty? == false then
    first_word(str).upcase
  else
    str.strip.upcase
  end
end

def remove_first_word(str)
  # given a string (usually a command line string), removes the first word
  # and strips whitespace at both ends and returns the resultant string.
  firstspace = str.index(' ')
  if firstspace == nil then
    ""
  else
    str[firstspace..-1].strip
  end
end

def valid_string_literal?(str)
  # returns boolean value depending if string is surrounded by quotation marks.
  # If str is to be stripped, it needs to be done prior to calling.
  (str.class == String) and (str[0] == "\"") and (str[str.size - 1] == "\"")
end 

def valid_int?(str)
  # returns a boolean depending on whether the string when converted
  # to integer, returns a value greater than or equal to zero
  # This would be better renamed as valid_plus_int? future_work
  (str.class == String) and str.to_i >= 0 and (str.match?(/[[:alpha:]]/) == false) and (str.match?(/[[:punct:]]/) == false)
end

def valid_num_range?(str)
  # returns a boolean depending on whether the string contains a valid range.
  # A valid range contains two dashes between two numbers; second number
  # has to be equal to or greater than first number; first number has to be
  # equal to or greater than 0.
  result = false
  if str.class == String then
    if str.match?(/^[0-9]+--[0-9]+$/) then
      nums = str.split("--").collect{|x| x.to_i}
      if (nums[0] >= 0) and (nums[1] > nums[0]) then result = true end
    end
  end
  return result
end

def contains_period?(str)
  # given a string, returns a boolean based on whether the string contains a period.
  str.strip.include?('.')
end

def num_range(str)
  # returns an array of integer from a string containing a numerical range.
  # The lower number of the range is first. If not a valid numerical range,
  # an empty array is returned.
  result = Array.new
  if valid_num_range?(str) then
    result = str.split("--").collect{|x| x.to_i}
  end
end

def resolve_num_or_numrange(str)
  # takes a string that represents either a numeric value or a random
  # numeric range, and resolves it into a final number. If it does not
  # correspond to a valid integer or a valid numeric range, 0 is returned.
  # Note that 0 might be returned even if it's a valid integer or numeric
  # range, since 0 is considered a valid number. Therefore 0 is not
  # automatically an error message. 
  if valid_int?(str) then
    str.to_i
  elsif valid_num_range?(str) then
    the_range = num_range(str)
    rand(the_range[0]..the_range[1])
  else
    0
  end
end

def valid_word_num?(str)
  # Returns a boolean depending on whether the string str contains a valid
  # word number, which would be a number with the letter W (case-insensitive)
  # after
  result = false
  if str.dup.upcase.match?(/^[0-9]+W$/) and (str.match?(/[[:punct:]]/) == false) and str.to_i >= 0 then result = true end
  return result
end

def valid_word_range?(str)
  # Returns a boolean depending whether the string contains a valid word range
  # a valid word range contains two dashes between a number and the letter "W"
  # first number has to be >= 0, second has to be > first.
  result = false
  if str.class == String then
    if str.dup.upcase.match?(/^[0-9]+W--[0-9]+W$/) then
      nums = str.upcase.split("W--").collect{|x| x.to_i}
      if (nums[0] >= 0) and (nums[1] > nums[0]) then result = true end
    end
  end
  return result
end

def word_range(str)
  # Returns an array of integer from a string containing a word range.
  # The lower number of the word range is first (i.e. at the 0 index)
  result = Array.new
  if valid_word_range?(str) then
    result = str.upcase.split("W--").collect{|x| x.to_i}
  end
  return result
end

def resolve_word_range(str)
  # Given a string (str) that is known to contain a word range,
  # returns a random integer number within the bounds of that range
  range_arr = word_range(str)
  result = nil
  if range_arr.size == 2 then
    result = rand(range_arr[0]..range_arr[1])
  end
  return result
end

def is_start?(str)
  # Given a string (str) representing a user command line, returns
  # a boolean that is true if the user entered a command
  # that starts a block (e.g. "GEN", "LOOP", "DESC"), false otherwise.
  if str.empty? == false then
    str.upcase.start_with?("LOOP ") or (str.upcase == "LOOP") or str.upcase.start_with?("GEN ") or (str.upcase.strip == "GEN") or str.upcase.start_with?("DESC ") or (str.upcase == "DESC")
  else
    false
  end
end

def is_end?(str)
  # Given a string (str) representing a user command line, returns
  # a boolean that is true if the user entered a command
  # that ends a block (e.g. "GENEND", "LOOPEND", "DESCEND"), false otherwise.
  if str.empty? == false then
    str.upcase.start_with?("LOOPEND") or (str.upcase == "END") or str.upcase.start_with?("GENEND") or str.upcase.start_with?("DESCEND")
  else
    false
  end
end

def word_count_str(thestring)
  # Given a string (thestring), returns its word count as an integer
  if thestring.strip.empty? == true then
    result = 0
  else
    result = thestring.strip.squeeze(" ").count(" ") + 1
    # exclude from counting markdown formatting characters or a dash as words
    if thestring.include?("# ") then
      result = result - 1
    end
    if thestring.include?( "> ") then
      result = result -1
    end
    if thestring.include?("\n\n--- ") then
      result = result -1
    end
    if thestring.include?(" \n# ") then
      result = result - 1
    end
    if thestring.include?(" \n ") then
      result = result - 1
    end
  end
  return result
end

def display(curr_state, cmdhash)
  # Displays the first N sentences (for positive values of N) on the screen
  # or the last N sentences on the screen (for negative values of N), or all
  # sentences on screen if no parameters are given. This function
  # does not alter the story state in any way. Please note that formatting
  # marks that are meaningful in markdown (e.g. blockquote mark > or the
  # heading or subeading marks # or ## etc will be displayed as-is
  # via the display command. Display should not be thought of as a direct
  # reflection of the output as it would appear in markdown; instead it is
  # mainly useful for diagnostic purposes for assessing the text of the story.
  # remember that commands such as newpara and newline count as a
  # sentence (a blank one) in the story.
  par = remove_first_word(cmdhash[:comline]).strip
  if par.split.size > 1 then
    # ERR_ID ACORNSQUASH
    stop_with_par_num_error.call("DISPLAY", cmdhash[:linenum], cmdhash[:comline], "0 or 1 numeric parameters", "#{par.split.size.to_s} parameters")
  end
  if par.split.size == 1 then
    nsent = par.split[0].strip
    if (nsent.match?(/^[\-]*[[:digit:]]+/) == false) or (nsent.to_i == 0) then
      # ERR_ID AMARANTH
      stop_with_par_value_error.call("DISPLAY", cmdhash[:linenum], cmdhash[:comline], "a non-zero numerical parameter", nsent)
    end
    n_int = nsent.to_i
  end
  puts "\n---BEGIN DISPLAY COMMAND #{cmdhash[:comline]} in line #{cmdhash[:linenum]}---"
  if par.split.size == 0 then
    puts curr_state["story_so_far"]
  else
    if n_int.abs > curr_state["story_so_far"].size then
      # WARN_ID APRICOT
      mild_warning.call("The number of sentences you specified is larger than the size of the story; displaying all sentences", "DISPLAY", cmdhash[:linenum], cmdhash[:comline])
      puts curr_state["story_so_far"]
    else
      if n_int > 0 then
        puts curr_state["story_so_far"][0, n_int]
      else
        puts curr_state["story_so_far"][n_int..-1]
      end
    end
  end
  puts "---END DISPLAY COMMAND #{cmdhash[:comline]} in line #{cmdhash[:linenum]}---"
end

def gen_parse(curr_state, cmdhash, gen_name, howmany)
  # parses commands within the gen command. Takes the current state, a
  # commandhash within the gen command (describing the desired variable
  # assignment), the name of the gen, and the desired number
  # of these gens, and assigns the user gen variables appropriately,
  # returning the new state. This function is called by gen_user_structure
  #
  # A command consists of a variable name within the gen, then a number of
  # how many items to return (this may include a random range),
  # then the name of the word or sentence set to retrieve items from.
  # The optional allunique parameter may be added, meaning that there will
  # be no duplication of these in one gen compared to other gens in this set.
  # For example, allunique is desirable for city names, since you
  # presumably want each of your cities to have a different name.
  # On the other hand, you may not need the allunique
  # parameter if you are selecting a character's favorite color, since
  # different characters may have the same favorite color.
  # When requesting more than one item in a list in a city/character/gen,
  # please note that multiples are always unique within that 1 city/
  # chracter/gen, for example "friends 3 default_female_names" will always
  # give 3 *different* names within that one gen. Adding the allunique
  # parameter indicates that items are additionally to be unique
  # across each of those gens, so in the above example adding allunique means
  # that different people may not share a same friend name.
  new_state = curr_state
  # first figure out if the command is formatted correctly
  # heck if cmdhash is a hash or an array
  if cmdhash.class == Array then
    # error - a looped structure was given instead of a single cmdhash
    # ERR_ID SOYBEAN
    lnum = new_state["curr_line"][:linenum].to_i + 1
    stop_with_general_command_error("You cannot have nested structures in this location", "GEN", lnum.to_s, "you have a nested structure such as GEN or LOOP")
  end
  new_state["curr_line"] = cmdhash
  allpars = cmdhash[:comline].strip
  # we should expect between 3 and 4 parameters
  if (allpars != "") and (allpars.upcase != "GENEND") and (allpars[0] != "#") then
    # we have a non-blank and non-end line.
    # Blank lines are allowed but we don't want to attempt to process them.
    splitted_pars = allpars.split
    if (splitted_pars.size > 4) or (splitted_pars.size < 3) then
      # ERR_ID RUNNERBEAN
      stop_with_par_num_error.call("GEN", cmdhash[:linenum], cmdhash[:comline], "3 - 4 parameters", splitted_pars.size.to_s)
    end
    # we have the right number of parameters
    # get first word and remainder
    var_name = first_word(allpars.downcase)
    # here if var already exists under this gen, we want to know about it
    info = access_value((gen_name + "." + var_name), new_state, :gen)
    if info[:exists] == true then
      # WARN_ID BANANA
      mild_warning.call("Assigning variable #{var_name} - variable already exists. Data will be overwritten", "GEN", cmdhash[:linenum], cmdhash[:comline])
    end
    assignment_pars = remove_first_word(allpars)
    num_gen = first_word(assignment_pars)
    # check if the numerical parameter is valid
    if (valid_int?(num_gen) == false) and (valid_num_range?(num_gen) == false) then
      # ERR_ID ARRACACHA
      stop_with_par_value_error.call("GEN", cmdhash[:linenum], cmdhash[:comline], "a valid number or numeric range in second argument", num_gen)
    end
    # need to resolve number before proceeding
    amount_int = resolve_num_or_numrange(num_gen)
    if amount_int <= 0 then
      # ERR_ID SORREL
      stop_with_par_value_error.call("GEN", cmdhash[:linenum], cmdhash[:comline], "a non-zero number", amount_int.to_s)
    end
    last_1or2_pars = remove_first_word(assignment_pars)
    # need to check that the first of the 2 last pars is a valid set of
    # words or sentences
    last_1or2_split = last_1or2_pars.strip.split
    if (last_1or2_split.size == 2) and (last_1or2_split[1].strip.upcase != "ALLUNIQUE") then
      # invalid final parameter
      # ERR_ID ARROWROOT
      stop_with_par_value_error.call("GEN", cmdhash[:linenum], cmdhash[:comline], "ALLUNIQUE", last_1or2_split[1])
    end
    # at this point we have 1 or 2 final parameters with the second being
    # ALLUNIQUE
    # check first of the last 2 pars
    if access_value(last_1or2_split[0].strip.downcase, new_state)[:exists] == false then
      # then those words or sentences do not exist
      # ERR_ID ARTICHOKE
      stop_with_unknown_variable_error(last_1or2_split[0]).call("GEN", cmdhash[:linenum], cmdhash[:comline])
    end
    if access_value(last_1or2_split[0].strip.downcase, new_state)[:unit_type] != :list then
      # then the variable is of the wrong type
      # ERR_ID SHALLOT
      stop_with_general_command_error("Incompatible variable type for #{last_1or2_split[0]}", "GEN", cmdhash[:linenum], cmdhash[:comline], "list", access_value(last_1or2_split[0].strip.downcase, new_state)[:unit_type].to_s)
    end
    # now there is a variable name, an existing vocab, and a valid number
    # requested to generate of these.
    vocab_choices = access_value(last_1or2_split[0].strip.downcase, new_state)[:value]
    to_exclude = []
    howmany.times{|one_gen|
      selected_items = select_random_unique.call(amount_int, vocab_choices, to_exclude)
      new_state["user_gens"][gen_name][one_gen][var_name] = selected_items
      if last_1or2_split.size == 2 then
        # we know from earlier in this function that this means
        # the ALLUNIQUE parameter is there
        to_exclude.concat(selected_items)
      end
    }
  end
  return new_state
end

def gen_user_structure(curr_state, info_arr)
  # Given an array of commands containing a user-defined GEN structure,
  # generates the appropriate gen structure and returns the current state
  # with the newly defined user gen in user_gens.
  # If the desired variable was previously in existence, it will be erased
  # and replaced by the new data here. In that situation, a warning will be
  # emitted to STDOUT but the program will continue.
  new_state = curr_state
  # get parameters of the first line
  pars = remove_first_word(info_arr[0][:comline]).strip
  # get remaining commands after first line
  remaining_commands = info_arr[1..-1]
  # parse parameters of first line
  if pars == "" or pars.strip.split.size < 1 then
    # ERR_ID RUTABAGA
    stop_with_par_num_error.call("GEN", curr_state["curr_line"][:linenum], curr_state["curr_line"][:comline])
  end
  if pars.strip.split.size == 1 then
    var_name = pars.strip.downcase
  else
    var_name = first_word(pars).strip.downcase
  end
  if access_value(var_name, curr_state, :gen)[:exists] == true then
    # WARN_ID BLACKBERRY
    mild_warning.call("Assigning variable #{var_name} - variable already exists. Data will be overwritten", "GEN", curr_state["curr_line"][:linenum], curr_state["curr_line"][:comline])
  end
  if contains_period?(var_name) then
    # ERR_ID ARUGULA
    stop_with_general_command_error("User-specified variable name #{var_name} invalid because it contains a period", "GEN", curr_state["curr_line"][:linenum], curr_state["curr_line"][:comline])
  end
  if pars.strip.split.size == 1 then
    user_amount = "1"
  else
    user_amount = pars.strip.split[1]
  end
  if valid_int?(user_amount) or valid_num_range?(user_amount) then
    amount = resolve_num_or_numrange(user_amount)
    user_amount = amount.to_s
  else
    # ERR_ID ASPARAGUS
    stop_with_syntax_error.call("GEN", curr_state["curr_line"][:linenum], curr_state["curr_line"][:comline])
  end
  if amount <= 0 then
    # ERR_ID SNOWPEA
    stop_with_par_value_error.call("GEN", curr_state["curr_line"][:linenum], curr_state["curr_line"][:comline], "greater than zero", amount.to_s)
  end
  new_state["user_gens"][var_name] = Array.new
  new_state["curr_gens"][var_name] = 0
  if pars.strip.split.size == 3 then
    desired_gender = remove_first_word(remove_first_word(pars).strip).strip.downcase
  else
    desired_gender = ""
  end
  # at this point we have a variable name (existing or not) and a parameter of
  # how many to generate.
  # If the male/female/nonbinary/binary/human/robot/all options are given, then
  # generate an appropriate name and pronouns for the requested gender(s).
  # If this parameter is not given, then no gender-specific name and pronouns
  # will be assigned to that specific user gen. For example, if generating
  # cities instead of characters, the user would not be wanting
  # gender pronouns and should therefore leave the gender parameter blank.
  # So, if you are generating characters, you should specify a gender
  # parameter (unless you plan to handle names and pronouns some different way)
  # Gender pronoun options are hard-coded into the program so user cannot
  # currently change these (except by changing the source code), but adding
  # support for user-specified pronouns (e.g. he/they) is a feature that
  # might be supported later future_work
  name_list = Array.new
  user_amount.to_i.times{|n|
    if desired_gender != "" then
      # something was specified in gender field, need to handle pronouns
      # and first name. They come as name, heshe, hisher, himher.
      if gender_set_exists?(new_state, desired_gender) == false then
        # the desired gender set definition does not exist
        # ERR_ID ADZUKIBEAN
        stop_with_general_command_error("desired gender #{desired_gender} is not defined", "GEN", curr_state["curr_line"][:linenum], curr_state["curr_line"][:comline])
      else
        # generate gender items
        r_gender = select_random_one.(new_state["gender_info"][desired_gender.to_sym])[0]
        new_state["user_gens"][var_name][n] = Hash.new
        # when assigning names, exclude ones already existing in the gen
        curr_name = select_random_one.(new_state["gender_info"][r_gender]["names"], name_list)
        new_state["user_gens"][var_name][n]["name"] = curr_name
        name_list << curr_name[0]
        new_state["user_gens"][var_name][n]["heshe"] = [new_state["gender_info"][r_gender]["pronouns"]["heshe"]]
        new_state["user_gens"][var_name][n]["hisher"] = [new_state["gender_info"][r_gender]["pronouns"]["hisher"]]
        new_state["user_gens"][var_name][n]["himher"] = [new_state["gender_info"][r_gender]["pronouns"]["himher"]]
        new_state["user_gens"][var_name][n]["manwoman"] = [new_state["gender_info"][r_gender]["pronouns"]["manwoman"]]
        new_state["user_gens"][var_name][n]["waswere"] = [new_state["gender_info"][r_gender]["pronouns"]["waswere"]]
        new_state["user_gens"][var_name][n]["isare"] = [new_state["gender_info"][r_gender]["pronouns"]["isare"]]
      end
    else
      new_state["user_gens"][var_name][n] = Hash.new
    end }
  # now move on to items which do not relate to gender
  new_state = remaining_commands.reduce(new_state){|changing_state, gencmdhash|
    gen_parse(changing_state, gencmdhash, var_name, user_amount.to_i)}
  return new_state
end

def store_desc(curr_state, info_arr)
  # When given the current state and info_arr an array containing
  # cmdhashes describing a code block (= a desc) including a desired
  # variable name, stores the code block under that name and returns
  # the updated state of the story. Desc names do not collide with
  # other user variable names as they do not occupy the same space.
  new_state = curr_state
  # get parameters of the first line
  pars = remove_first_word(info_arr[0][:comline]).strip
  if pars.split.size != 1 then
    # ERR_ID BRUSSELSPROUT
    stop_with_par_num_error.call("DESC", info_arr[0][:linenum], info_arr[0][:comline], "one parameter only, the name of the variable for storing this desc", "#{pars.split.size.to_s} parameters")
  end
  # get remaining commands after first line
  remaining_commands = info_arr[1..-2]
  varname = pars.downcase
  new_state["user_descs"][varname] = remaining_commands
  return new_state
end

def call(curr_state, cmdhash)
  # Takes the current state and a command hash describing the call of a
  # desc, sends the desc to be executed, and returns the updated state.
  pars = remove_first_word(cmdhash[:comline]).strip
  if pars.split.size != 1 then
    # ERR_ID CABBAGE
    stop_with_par_num_error.call("CALL", cmdhash[:linenum], cmdhash[:comline], "one parameter only, the name of the desc to be called", "#{pars.split.size.to_s} parameters")
  end
  varname = pars.downcase
  # switch this out to make proper variable call
  desc_info = access_value(varname, curr_state, :desc)
  if desc_info[:exists] == false then
    # ERR_ID CHICORY
    stop_with_general_command_error("Unable to call the desc #{varname} as this desc does not exist or was not defined prior to calling it", "CALL", cmdhash[:linenum], cmdhash[:comline])
  end
  if (desc_info[:unit_type] != :list) or (desc_info[:value] == nil) then
    # ERR_ID SEQUOIA
    stop_with_general_command_error("Unable to call the desc #{varname} as it cannot be found or is of an unexpected format", "CALL", cmdhash[:linenum], cmdhash[:comline])
  end
  new_state = loop_iterator(curr_state, desc_info[:value], 0, 1, :cycle)
  return new_state
end

def word_count_arr(arr_of_string)
  # The main word count function. Given an primary array of strings, it
  # returns the number of words in that array of string.
  if arr_of_string == nil then
    0
  else
    arr_of_string.inject(0) {|tot, sentences| tot + word_count_str(sentences)}
  end
end

def arrjoin(orig_arr, to_add, curr_state, command="WORDJOIN")
  # When given an array of strings (orig_arr), will concatenate the
  # string(s) from that in to_add to the ones in orig_arr, returning
  # a new array containing the concatenated strings.
  # to_add may be a string literal or a user variable of type :list.
  # If to_add is a list variable of a different length to orig_arr, then
  # the shorter array will repeat until it reaches the length of the longer
  # array. Typically only called by assign_parse in :wordjoin mode.
  if valid_string_literal?(to_add.strip) then
    add_arr = [to_add.strip[1..-2]]
  else
    add_info = access_value(to_add.strip.downcase, curr_state)
    if add_info[:exists] == false then
      # ERR_ID SWEETPOTATO
      stop_with_unknown_variable_error(to_add).call(command, curr_state["curr_line"][:linenum], curr_state["curr_line"][:comline], "an existing variable of type list or a string literal", to_add)
    end
    if add_info[:unit_type] != :list then
      # ERR_ID TOMATO
      stop_with_general_command_error("you specified an incompatible variable type", command, curr_state["curr_line"][:linenum], curr_state["curr_line"][:comline], "a variable of type list or a string literal", to_add)
    end
    add_arr = add_info[:value]
  end
  if (add_arr != [""]) and (add_arr.empty? == false) then
    # we have something to add to the original array
    if orig_arr.empty? == true then
      final_arr = add_arr
    else
      # neither the original array nor the array to add are empty
      add_arr_size = add_arr.size
      orig_arr_size = orig_arr.size
      final_arr = Array.new
      if add_arr_size >= orig_arr_size then
        add_arr.each_with_index{|item, ind|
          final_arr << orig_arr[ind % orig_arr_size] + item}
      else
        orig_arr.each_with_index{|item, ind|
          final_arr << item + add_arr[ind % add_arr_size]}
      end
    end
  else
    # empty data was added
    final_arr = orig_arr
  end
  return final_arr
end

def convert_case(style, item)
  # given a style of case-conversion (:upcase, :lowcase, :supcase, :slowcase)
  # and a string (item), converts case of item as desired, and returns
  # the case-converted string.
  if item != "" then
    case style
    when :upcase
      item.upcase
    when :lowcase
      item.downcase
    when :supcase
      if item.size == 1 then
        item.upcase
      else
        item[0].upcase + item[1..-1]
      end
    when :slowcase
      if item.size == 1 then
        item.downcase
      else
        item[0].downcase + item[1..-1]
      end
    else
      ""
    end
  else
    ""
  end 
end

def op_calc(result_so_far, one_item, style, curr_state, op)
  # This function returns the value of result_so_far after addition or
  # subtraction. It evaluates the result of adding or subtracting one_item
  # such as a string literal or variable from the result_so_far.
  # Typically called by calc_plus_minus which evaluates the right hand
  # side of an assignment statement. op may be "+" or "-"
  command = get_command(curr_state["curr_line"][:comline])
  final_result = result_so_far
  if style == :list then
    allowable_types = Set[:stringlit, :list]
  elsif style == :catalog then
    allowable_types = Set[:list, :catalog]
  elsif style == :genall then
    allowable_types = Set[:genall]
  else
    # ERR_ID BAMBOOSHOOT
    stop_with_general_command_error("Type mismatch error when attempting to assign #{one_item} to a variable", command, curr_state["curr_line"][:linenum], curr_state["curr_line"][:comline])
  end
  # first determine if pieces could match, then do the final math
  if valid_string_literal?(one_item.strip) then
    one_type = :stringlit
    one_value = one_item.strip[1..-2]
  else
    # if not a literal, we need to look up to see if exists
    lookup = access_value(one_item.strip, curr_state)
    if lookup[:exists] == false then
      # ERR_ID BEETROOT
      stop_with_unknown_variable_error(one_item).call(command, curr_state["curr_line"][:linenum], curr_state["curr_line"][:comline])
    end
    # if we are here then we have an existing variable
    one_type = lookup[:unit_type]
    one_value = lookup[:value]
  end
  # first check if the types are allowable
  if allowable_types.member?(one_type) == false then
    # ERR_ID BELLPEPPER
    stop_with_general_command_error("Type mismatch error when attempting to add or subtract #{one_item} to a variable - they are not of compatible types", command, curr_state["curr_line"][:linenum], curr_state["curr_line"][:comline])
  end
  if op == "+" then
    # + operation for :list is defined as adding the array or literal
    # to result_so_far and then applying uniq
    if style == :list then
      if one_value.class == String then
        final_result = (result_so_far + [one_value]).uniq
      else
        final_result = (result_so_far + one_value).uniq
      end
    end
    if style == :catalog then
      if one_value.class == Array then
        final_result[one_item.strip.downcase] = one_value
      else
        final_result = result_so_far.merge(one_value)
      end
    end
    if style == :genall then
      final_result = (result_so_far + one_value).uniq
    end
  elsif op == "-" then
    # calc subtracting it, typically result_so_far minus one_item but
    # depends on data structures. For :catalog, subtraction is based
    # on keys only. No attempt is made to check whether a key present in
    # both items has the same value or not.
    # For :genall, subtraction assumes all items of the subtracted gen are
    # the same in both. If even one thing is a bit different, it won't
    # subtract. Thus, if subtracting, it's important for the user to
    # identify the item being subtracted just before the subtraction
    # (either that, or to not modify any of the item properties after
    # its creation).
    if style == :list then
      if one_value.class == String then
        final_result = (result_so_far - [one_value]).uniq
      else
        final_result = (result_so_far - one_value).uniq
      end
    end
    if style == :catalog then
      if one_value.class == Array then
        final_result = result_so_far.reject{|key, value|
          key == one_item.strip.downcase}
      else
        final_result = one_value.keys.reduce(result_so_far){|changing, onekey|
          changing.reject{|key, value|
            key == onekey}
        }
      end
    end
    if style == :genall then
      final_result = (result_so_far - one_value).uniq
    end
  else
    # ERR_ID BLACKEYEDPEA
    stop_with_general_command_error("Please contact the programmer. Attempting to evaluate the variable #{one_item} without a + or - operation. This situation should theoretically not arise", command, curr_state["curr_line"][:linenum], curr_state["curr_line"][:comline])
  end
  return final_result
end

def calc_plus_minus(returnable_datatype, splitted_plus_item, style, curr_state, cmdhash)
  # Returns the final result in the appropriate data structure for that
  # assignment statement. Evaluates the right hand side of an assignment
  # statement, which may contain both + and - operations.
  # This function is typically called from assignment_value.
  splitted_minus = splitted_plus_item.split(" - ")
  # the first item of the splitted minus will be a plus, since we had already
  # splitted on plus in the previous function
  result = op_calc(returnable_datatype, splitted_minus[0], style, curr_state, "+")
  if splitted_minus.size > 1 then
    result = splitted_minus.drop(1).reduce(op_calc(returnable_datatype, splitted_minus[0], style, curr_state, "+")){|changing, item|
      op_calc(changing, item, style, curr_state, "-")}
  end
  return result
end

def assignment_value(rhs_str, style, curr_state, cmdhash)
  # Given the right hand side (of the '=') for an assignment command as
  # a string (rhs_str), computes the value of that desired assignment.
  # Returns that value as either an array or a hash, whichever is
  # dictated by the assignment command.
  # Typically designed to be called by assign_parse.
  # style can be :list, :catalog, or :genall.  cmdhash is only
  # used for error reporting purposes. curr_state is for lookups, except
  # in the case of gens where the pointer to the active item of a gen
  # may be modified during a subtractive assignment, to continue to point
  # to the same active item.
  # values are computed from left to right.
  command = get_command(cmdhash[:comline])
  if style == :list then
    result = Array.new
  elsif style == :catalog then
    result = Hash.new
  elsif style == :genall then
    result = Array.new
  else
    # ERR_ID BOKCHOY
    stop_with_general_command_error("Type mismatch error between command and value", command, cmdhash[:linenum], cmdhash[:comline])
  end
  # get splitted pluses, split them on minus, and calc value
  splitted_plus = rhs_str.split(" + ")
  # for each of the above, need to split on minus
  # if the splitted minus is 1 item, add it to result
  # if it's more than one, add first, then subtract others
  # if any item is not in allowable types (test every one for stringlit) then
  # stop with error. Otherwise keep evaluating.
  result = splitted_plus.reduce(result){|changing, arritem|
    calc_plus_minus(changing, arritem, style, curr_state, cmdhash)}
  return result
end

def assign_value(style, curr_state, target, value)
  # Returns state. Given a target variable (target) which may or may not be
  # present in curr_state, and a value, assigns the value to the target
  # variable in curr_state, returning a new udpated state with the
  # variable assigned.
  # style parameters are as for assign_parse :list, :catalog, :genall,
  # :wordjoin, :upcase, :lowcase, :supcase, or :slowcase
  # future_work Decide whether this function could benefit from some
  # tightening up, since the style parameter is barely used. Any proposed
  # change may affect assign_parse feeding into this, and
  # access_value that is called by this. access_value should also
  # ideally be altered to allow the ability to assign a new variable via
  # the nesting of the if/then statements inside it - ultimately that ability
  # would affect the calls made here and in any other function calling
  # access_value in :change mode.
  new_state = curr_state
  targetname = target.strip.downcase
  info = access_value(targetname, curr_state)
  if info[:exists] == true
    # we need to update a current variable
    new_state = access_value(targetname, curr_state, :all, :change, value)
  else
    # we need to assign a new variable
    if style == :genall then
      new_state["user_gens"][targetname] = value
    else
      new_state["user_vars"][targetname] = value
    end
  end
  return new_state
end

def assign_parse(style, curr_state, cmdhash)
  # Takes the command line of an assign statement, parses it,
  # updates values as required, and returns the new state.
  # style represents type of assignment, and is either :list, :catalog,
  # :genall, :wordjoin, :upcase, :lowcase, :supcase, or :slowcase
  new_state = curr_state.clone
  allpars = remove_first_word(cmdhash[:comline])
  command = get_command(cmdhash[:comline])
  l_r = split_l_r(allpars)
  if l_r[:error] != 0 then
    # ERR_ID BROCCOLI
    stop_with_general_command_error("Too few arguments given or ' = ' missing", command, cmdhash[:linenum], cmdhash[:comline])
  else
    # we at least have a left and right side to the equals sign
    rhs = l_r[:r]
    lhs = l_r[:l]
    rsplit = rhs.split
    lsplit = lhs.split
    rvalue = nil
    if style == :wordjoin then
      # First check there is more than 1 parameter
      # The concatenation evaluates l to r. Valid parameters are
      # string literals and lists. Returns a list which it assigns
      # to variables on left hand side.
      rsplit_plus = rhs.split(" + ")
      if rsplit_plus.size < 2 then
        # ERR_ID SPRINGONION
        stop_with_par_num_error.call(command, cmdhash[:linenum], cmdhash[:comline], "2 parameters on the right hand side", "#{rsplit_plus.size.to_s} parameters")
      end
      # rvalue will either contain 1 item (if all pars are string literals)
      # or multiple items (if there is at least 1 list in pars)
      rvalue = rsplit_plus.reduce(Array.new){|changing, arritem|
        arrjoin(changing, arritem, curr_state)}
    elsif (style == :upcase) or (style == :lowcase) or (style == :supcase) or (style == :slowcase) then
      # this only works on lists and string literals
      rvar = rhs.strip
      if valid_string_literal?(rvar) then
        to_change = [rvar.strip[1..-2]]
      else
        to_change_info = access_value(rvar.strip.downcase, curr_state)
        if to_change_info[:exists] == false then
          # ERR_ID TURNIP
          stop_with_unknown_variable_error(rvar).call(command, cmdhash[:linenum], cmdhash[:comline])
        end
        if to_change_info[:unit_type] != :list then
          # ERR_ID WASABI
          stop_with_general_command_error("Incompatible type specified in variable #{rvar}", command, cmdhash[:linenum], cmdhash[:comline], "a variable of type list")
        end
        to_change = to_change_info[:value]
      end
      rvalue = to_change.map{|arritem| convert_case(style, arritem)}
    elsif (rsplit.size == 2) and (valid_int?(rsplit[1].strip) or valid_num_range?(rsplit[1].strip)) then
      # We have 2 parameters with the second one a number, which means we need
      # to randomly select the appropriate number of things. num should
      # be greater than zero.
      possible_value = access_value(rsplit[0].strip, curr_state)
      howmany = 0
      howmany = resolve_num_or_numrange(rsplit[1].strip)
      if howmany <= 0 then
        # ERR_ID CAPER
        stop_with_general_command_error("You are trying to select zero or fewer items from a selection. You must select one or more", command, cmdhash[:linenum], cmdhash[:comline])
      else
        # we have 1 or more unique items desired to select from the
        # (hopefully) existing variable on rhs.
        # First check if variable exists, then check for type vs style
        if possible_value[:exists] == true then
          # variable exists, next check type
          if possible_value[:unit_type] == style then
            # the types match; proceed with selection
            rvalue = select_random_unique.call(howmany, possible_value[:value])
          else
            # ERR_ID CARROT
            stop_with_general_command_error("The name of your command does not match the type of your variable #{rsplit[0]}", command, cmdhash[:linenum], cmdhash[:comline])
          end
        else
          # ERR_ID CASSAVA
          stop_with_unknown_variable_error(rsplit[0]).call(command, cmdhash[:linenum], cmdhash[:comline])
        end
      end
    else
      # this is the general use case.
      # In this case we have multiple parameters here that need splitting
      # and evaluating. Send to another function.
      rvalue = assignment_value(rhs, style, curr_state, cmdhash)
    end
    # Can now make the assignments after having evaluated the RHS.
    # Remember the LHS can include multiple vars. 
    new_state = lsplit.reduce(new_state){|changing, arritem|
      assign_value(style, changing, arritem, rvalue)}
    if style == :genall then
      # Need to handle gen pointers.  if no key yet for the curr ptr of a
      # gen (or if it is greater than size of array -1, or is nil),
      # assign it to zero.
      lsplit.each{|gen|
        if gen_ptr_value(new_state, gen) == nil then
          new_state["curr_gens"][gen.strip.downcase] = 0
        end}
      # This will have the net effect that adding gens will result in the
      # pointer staying with the same gen, while this is not necessarily
      # the case with subtracting gens.
    end
  end
  return new_state
end

def split_l_r(str, delim=" = ")
  # Designed for splitting a string into exactly 2 parts.
  # Given a query string and a delimiter string to split on, returns
  # the stripped left and right portions of that string and a zero-value
  # error. These data, if no errors occurred, are returned as a hash with
  # l and r as the keys and an error key value of zero. If an error occurred,
  # a single-item hash is returned with a key of error, containing a
  # non-zero value.
  # If the l and/or r values are empty (which could be the case if they contain
  # only a space and we are delimiting on something other than space), that is
  # considered an error.
  splitted = str.split(delim)
  if splitted.size < 2 then
    {error: 1}
  elsif splitted.size > 2 then
    {error: 2}
  else
    left = splitted[0].strip
    right = splitted[1].strip
    if (left == "") or (right == "") then
      {error: 3}
    else
      {l: left, r: right, error: 0}
    end
  end
end

def assigngen(curr_state, cmdhash)
  # given the current story state, returns the new story state upon
  # assigning or updating user gens
  assign_parse(:genall, curr_state, cmdhash)
end

def assignlist(curr_state, cmdhash)
  # given the current story state, returns the new story state upon
  # assigning or updating lists
  assign_parse(:list, curr_state, cmdhash)
end

def assigncatalog(curr_state, cmdhash)
  # given the current story state, returns the new story state upon
  # assigning of updating catalogs
  assign_parse(:catalog, curr_state, cmdhash)
end

def wordjoin(curr_state, cmdhash)
  # given the current state, returns the new state upon creating a new
  # variable which is made by joining string literals to a list,
  # or other variables of type list to a list
  assign_parse(:wordjoin, curr_state, cmdhash)
end

def upcase(curr_state, cmdhash)
  # given the current state, returns the new state upon creating a new
  # variable which is made by converting all letters in a string literal
  # or all items in a list to uppercase.
  assign_parse(:upcase, curr_state, cmdhash)
end

def lowcase(curr_state, cmdhash)
  # given the current state, returns the new state upon creating a new
  # variable which is made by converting all letters in a string literal
  # or all items in a list to lowercase.
  assign_parse(:lowcase, curr_state, cmdhash)
end

def supcase(curr_state, cmdhash)
  # given the current state, returns the new state upon creating a new
  # variable which is made by converting only the first letter in a string
  # literal or the first letter of all items in a list to uppercase.
  assign_parse(:supcase, curr_state, cmdhash)
end

def slowcase(curr_state, cmdhash)
  # given the current state, returns the new state upon creating a new
  # variable which is made by converting only the first letter in a string
  # literal or the first letter of all items in a list to lowercase.
  assign_parse(:slowcase, curr_state, cmdhash)
end

def assign_refgender_var(curr_state, varname, rhs)
  # Given the current state and a target variable name (varname), assigns
  # the value of rhs to that varname, returning the updated state. Called
  # by refgender.
  new_state = curr_state.clone
  varname_info = split_l_r(varname.strip.downcase, ".")
  if varname_info[:error] != 0 then
    # ERR_ID CAULIFLOWER
    stop_with_general_command_error("You are expected to assign to gender-specific variable names", "REFGENDER", curr_state["curr_line"][:linenum], curr_state["curr_line"][:comline], "male.names, female.names, etc", varname)
  end
  gender_name = varname_info[:l].strip.downcase
  gender_var = varname_info[:r].strip.downcase
  if new_state["gender_info"].include?(gender_name) == false then
    # ERR_ID CELERY
    stop_with_general_command_error("Unable to assign to #{gender_name} - no such gender defined", "REFGENDER", curr_state["curr_line"][:linenum], curr_state["curr_line"][:comline])
  end
  if new_state["gender_info"][gender_name].include?(gender_var) == false then
    # ERR_ID CHAYA
    stop_with_unknown_variable_error(gender_var).call("REFGENDER", curr_state["curr_line"][:linenum], curr_state["curr_line"][:comline])
  end
  new_state["gender_info"][gender_name][gender_var] = rhs
  return new_state
end

def refgender(curr_state, cmdhash)
  # Given the current state and the command hash containing a REFGENDER
  # command, returns the new state upon assigning of gender variables
  # specified by the user. This gives the user a way to override the
  # gender defaults given by the program. This is only implemented
  # for names so far (e.g. genname.name) but in future may be extended
  # to other gender variables such as pronouns future_work
  # For names, the format of the command looks like this:
  # REFGENDER male.names = malenames
  # where the right hand side must correspond to a single user variable
  # in list format (this may be a variable from wfolder, for example).
  # In other words, manually typing a series of strings will not work
  # in REFGENDER as it would in ASSIGNLIST, but if such an approach
  # is desired by the user, a preceding ASSIGNLIST command will work,
  # where the series of manually typed strings are assigned to a
  # user variable.
  new_state = curr_state.clone
  allpars = remove_first_word(cmdhash[:comline].strip)
  par_info = split_l_r(allpars)
  if par_info[:error] != 0 then
    # ERR_ID CHERRYTOMATO
    stop_with_syntax_error.call("REFGENDER", cmdhash[:linenum], cmdhash[:comline], "gender.names = your_variable")
  end
  lhs = par_info[:l]
  rhs = par_info[:r]
  if rhs.split.size != 1 then
    # ERR_ID CHICKPEA
    stop_with_syntax_error.call("REFGENDER", cmdhash[:linenum], cmdhash[:comline], "only 1 variable on the right hand side", "#{rhs.split.size.to_s}: #{rhs}")
  end
  # evaluate rhs
  varname = rhs.strip.downcase
  var_info = access_value(varname, new_state)
  if var_info[:exists] == false then
    # ERR_ID CHIVES
    stop_with_unknown_variable_error(varname).call("REFGENDER", cmdhash[:linenum], cmdhash[:comline])
  end
  if var_info[:unit_type] != :list then
    # ERR_ID COLLARDGREEN
    stop_with_general_command_error("User variable #{varname} is not of a compatible type", "REFGENDER", cmdhash[:linenum], cmdhash[:comline], "variable of type :list", "variable of type #{var_info[:unit_type].to_s}")
  end
  # we now have a valid variable on rhs, assign it to lhs variable(s)
  lhs_arr = lhs.strip.split
  new_state = lhs_arr.reduce(new_state){|changing, arritem|
    assign_refgender_var(changing, arritem, var_info[:value])}
  return new_state
end

def recite(curr_state, cmdhash)
  # A form of assignment. Converts an array of items into a readable list
  # and stores it in a new list variable, returning the new state.
  # For example ["apple", "pear", "banana"] will become
  # "apple, pear and banana". That sentence will be assigned
  # to the new variable. Takes the form
  # RECITE newvarname = existingvar + "str"(optional) + all(optional)
  # the str is an optional string literal argument, which if present,
  # prepends to each item.
  # Typical usage is for str to be "a " or "the ".
  # + all is to indicate use across an entire gen,
  # for example person.carrying + "a " + all
  # would list the carrying variable for all persons in this gen.
  # without all, it would only list the items carried for the current
  # item of the gen.
  # multiple vars may be present on the left hand side of the equals sign.
  # This function produces a unique list. This
  # is something that can be easily changed for future work if desired.
  new_state = curr_state.clone
  varstyle = :all
  allflag = false
  pars = remove_first_word(cmdhash[:comline]).strip
  par_info = split_l_r(pars)
  if par_info[:error] != 0 then
    # ERR_ID CRESS
    stop_with_syntax_error.call("RECITE", cmdhash[:linenum], cmdhash[:comline], "newvarname = existingvar + prepend-string-literal[optional] + all[optional]")
  end
  rhs = par_info[:r].strip.split(" + ")
  lhs = par_info[:l].strip.split
  if (rhs.size < 1) or (rhs.size > 3) or (lhs.size < 1) then
    # ERR_ID CUCUMBER
    stop_with_syntax_error.call("RECITE", cmdhash[:linenum], cmdhash[:comline], "newvarname = existingvar + prepend-string-literal[optional] + all[optional]")
  end
  # rhs 1st par
  existingvar = rhs[0].strip.downcase
  if contains_period?(existingvar) == true then
    varstyle = :gen
  end
  if rhs.size >= 2 then
    # check if valid string literal
    if valid_string_literal?(rhs[1].strip) == false then
      # either it's an error, or we are expecting the "all" parameter.
      if rhs[1].strip.downcase == "all" then
        allflag = true
      else
        # ERR_ID WATERCRESS
        stop_with_par_value_error.call("RECITE", cmdhash[:linenum], cmdhash[:comline], "a valid string literal in quotes or the word 'all' without quotes", rhs[1].strip)
      end
    end
    if allflag == false then
      prepend = rhs[1].strip[1..-2]
    else
      prepend = ""
    end
    if (rhs.size >= 3) then
      if rhs[2].strip.downcase != "all" then
        # ERR_ID WHEATGRASS
        stop_with_par_value_error.call("RECITE", cmdhash[:linenum], cmdhash[:comline], "the word 'all' at the end, without quotes", rhs[2].strip)
      end
      allflag = true
      # at this point we know that the style should be :gen since we
      # have a 3rd parameter specifying all
    end
  else
    prepend = ""
  end
  existingvar_info = access_value(existingvar, curr_state)
  if existingvar_info[:exists] == false then
    # ERR_ID DAIKON
    stop_with_unknown_variable_error(existingvar).call("RECITE", cmdhash[:linenum], cmdhash[:comline], "a non-empty variable", existingvar)
  end
  if (existingvar_info[:unit_type] != :list) then
    # ERR_ID DILL
    stop_with_general_command_error("The referenced variable #{existingvar} must be a list", "RECITE", cmdhash[:linenum], cmdhash[:comline])
  end
  # at this point, if we have a variable, if it's a gen with all as a
  # parameter, we have to get all the desired items
  if (varstyle == :gen) and (allflag == true) then
    the_list = access_gen_item_all(existingvar, curr_state).uniq
  else
    the_list = existingvar_info[:value].uniq
  end
  if the_list.size == 0 then
    # WARN_ID CURRANT
    severe_warning.call("Empty variable #{existingvar}", "RECITE", cmdhash[:linenum], cmdhash[:comline])
  end
  rhs_val = arr_2_sentence(the_list, prepend)
  new_state = lhs.reduce(new_state){|changing, arritem|
    assign_value(:list, changing, arritem, [rhs_val])}
  return new_state
end

def a_an(one_sentence)
  # Given a string sentence (one_sentence), returns it with
  # 'a' replaced with 'an' where needed. Note: This would be better
  # implemented to handle mixed case situations future_work
  tempstr = one_sentence.dup
  if one_sentence.match?(/\ a\ [aieou]/) then
    tempstr.scan(/\ a\ [aeiou]/){|match|
      startmatch = tempstr.dup.index(match)
      tempstr = tempstr.dup.insert(startmatch + 2, "n")}
  end
  if  one_sentence.match?(/^a\ [aieou]/) then
    tempstr.scan(/^a\ [aeiou]/){|match|
      startmatch = tempstr.dup.index(match)
      tempstr = tempstr.dup.insert(startmatch + 1, "n")}
  end
    if one_sentence.match?(/\ A\ [AEIOU]/) then
    tempstr.scan(/\ A\ [AEIOU]/){|match|
      startmatch = tempstr.dup.index(match)
      tempstr = tempstr.dup.insert(startmatch + 2, "N")}
  end
  if  one_sentence.match?(/^A\ [AEIOU]/) then
    tempstr.scan(/^A\ [AEIOU]/){|match|
      startmatch = tempstr.dup.index(match)
      tempstr = tempstr.dup.insert(startmatch + 1, "N")}
  end
  return tempstr
end

def format_sentence(sentence, lettercode, curr_state, style = :md)
  # formats 1 sentence string according to 1 lettercode and returns the
  # formatted version as a string.
  # curr_state is there merely to look up the current program line
  # for error reporting purposes.
  # currently style = :md has no other options; in a future release I want
  # to allow style :html future_work
  # Valid lettercodes for style = :md are as follows:
  # C - capitalization of first letter
  # A - a / an where needed
  # G - single carriage return at end of sentence
  # N - this sentence starts on a new paragraph
  # Z - new paragraph after this sentence
  # T - blockquote/ indentation - this sentence starts a new line with
  # a blockquote. Note that blockquote operates on the paragraph level,
  # and ends upon starting a new paragraph (not just a new line)
  # without blockquotes. It is therefore the user's responsibility that
  # if multiple consecutive sentences within the same blockquote are
  # desired, then drop the T from the subsequent formatting, otherwise
  # each blockquote sentence will start on a new line. 
  # P - period
  # S - space at end
  # H - horizontal line after the sentence. This places a blank line by
  # itself between the sentence and the horizontal line (otherwise it
  # would get confused with markdown alternate heading syntax).
  # J - horizontal line before the sentence
  # Q - quotation marks surrounding the sentence
  # M - comma at end
  # K - question mark at end
  # I - italics - please note that this adds a space on either side of
  # the sentence as well. This is to avoid stretches of subsequent
  # sentences turning into bolded items from having 2 asterisks next to
  # each other. Users who wish to avoid the spaces may add
  # italic formatting marks through an ASSIGN statement before and after
  # the set of consecutive italic sentences, instead of using FORMAT.
  # B - bold - please note that this adds a space on either side of
  # the sentence as well. This is to avoid stretches of subsequent
  # sentences turning into both bold and italics, or otherwise
  # causing the markdown viewer confusion from multiple asterisks next to
  # each other. Users who wish to avoid the spaces may add their own
  # formatting marks through an ASSIGN statement before and after
  # the set of consecutive italic sentences, instead of using FORMAT.
  # likewise for users seeking bolded and italicized text together.
  # L - this sentence starts on a new line
  # Y - new line after this sentence
  # E - exclamation mark
  # D - heading beginning and ending with newline (similar to <h1> tag in HTML)
  # F - subheading beginning and ending with newline(similar to <h2> tag in HTML)
  # X - no formatting at all
  case lettercode
  when "X"
    sentence
  when "P"
    sentence + "."
  when "S"
    sentence + " "
  when "K"
    sentence + "?"
  when "E"
    sentence + "!"
  when "M"
    sentence + ","
  when "C"
    sentence.sub(/[[:alpha:]]/){|c| c.upcase}
  when "G"
    sentence + "\n"
  when "A"
    a_an(sentence)
  when "Q"
    "\"" + sentence + "\""
  when "B"
    " **" + sentence + "** "
  when "I"
    " *" + sentence + "* "
  when "L"
    "  \n" + sentence
  when "H"
    sentence + "  \n\n---   \n"
  when "J"
    "  \n\n---   \n" + sentence
  when "Y"
    sentence + "  \n"
  when "N"
    "\n\n" + sentence
  when "Z"
    sentence + "\n\n"
  when "T"
    "  \n> " + sentence
  when "D"
    "  \n# " + sentence + "  \n"
  when "F"
    "  \n## " + sentence + "  \n"    
  else
    # ERR_ID ENDIVE
    stop_with_general_command_error("Unknown code: #{lettercode}", "FORMAT", curr_state["curr_line"][:linenum], curr_state["curr_line"][:comline])
  end
end

def standard_write(curr_state, sentence_value, word_value, order_style, curr_cond, stop_cond, inc_style, desired_index = 0, format = curr_state["format"])
  # returns the new state of the story after writing the requested
  # amount to the story_so_far. This function is typically called by the
  # write function. Typechecking is not the
  # responsibility of standard_write; this is done earlier
  # by the function calling this function.
  # sentence_value is the value of a list or catalog of sentences,
  # word_value is the value of a list of words, order_style may be either
  # "random" or "order" (see write function for more details).
  # curr_cond & stop_cond values depend on whether inc_style is :cycle or :word
  # The optional parameter desired_index indicate which index to pick from
  # sentence_value; when order_style is "random" this index number is randomly
  # assigned; when order_style is "order" this index starts at 0 and is
  # later incremented. The optional format parameter indicates the desired
  # formatting as per the format function.
  if inc_style == :cycle then
    new_curr = curr_cond + 1
  else
    # we know inc_style is :word
    new_curr = word_count_arr(curr_state["story_so_far"])
  end
  if curr_cond >= stop_cond then
    return curr_state
  else
    # need to select sentence, wordsub it, write it, and increment curr_cond
    # Be aware sentence_value may be a catalog or a list, although it would
    # have been converted into an array before this.
    # Get 1 sentence and wordsub it.
    # If order is random, pick random item from array, if string then it's the
    # desired sentence, else the item is an array, get 2nd item (= last item)
    # which is ALSO an array, pick random 1 from that list of sentences.
    indexed_item = sentence_value[desired_index % sentence_value.size]
    if indexed_item.class == String then
      single_sentence = indexed_item
    else
      # it's a hash turned into an array
      # resolve to single sentence
      single_sentence = select_random_one.call(indexed_item[1])[0]
      if single_sentence == nil then
        # ERR_ID SPINACH
        stop_with_par_value_error.call("WRITE", curr_state["curr_line"][:linenum], curr_state["curr_line"][:comline], "your sentence variable should not contain any empty values - if a catalog, this means none of its lists should be empty", "an empty value")
      end
    end
    subbed_sentence = one_sentence_suball(single_sentence, curr_state, word_value)
    # format the sentence
    format_chars = format.chars
    formatted_sentence = format_chars.reduce(subbed_sentence){|changing_s, formatcode| format_sentence(changing_s, formatcode, curr_state)}
    curr_state["story_so_far"] << formatted_sentence
    # need to determine next desired_index.
    # If we are doing "order", then we don't worry about the previous
    # sentence being the same or not (because presumably the user has a
    # reason for enforcing a particular order, regardless).
    # If we are doing "random" then we need to consider what to do.
    # In case of a list or catalog, if list size > 1 then remove curr index
    # from consideration for next index
    # We do have to accept a same-as-previous sentence without trying
    # to force a definitely different sentence, otherwise multiple indices
    # with multiple same sentences as the only sentence will result
    # in an endless loop.
    if order_style == "order" then
      new_index = desired_index + 1
    else
      # order_style is "random"
      if sentence_value.size == 1 then
        new_index = 0
      else
        new_index_choices = (0..(sentence_value.size - 1)).to_a - [desired_index]
        new_choice_index = rand(0..(new_index_choices.size - 1))
        new_index = new_index_choices[new_choice_index]
      end
    end
    standard_write(curr_state, sentence_value, word_value, order_style, new_curr, stop_cond, inc_style, new_index)
  end
end

def write(curr_state, cmdhash)
  # Returns story state with additional writing added. Parameters:
  # catalog or list of sentences, catalog (NOT list) of words;
  # amount (either a numeric amount of times, or a number of words,
  # or a range of either); ordered = "random" (default) or "order"
  # (i.e. whether order of sentences is random or not). If amount
  # is not specified, it is taken to be 1 (i.e. 1 sentence only).
  # 0 is an allowable amount.
  # the user may specify the reserved word SFOLDER to indicate all
  # sentences that were grabbed from computer folder at the start
  # (this does not include sentences added through ASSIGN commands).
  # The analagous reserved word for words grabbed from computer folder
  # is WFOLDER.
  # Note - in the case where "order" is being used with a list of sentences,
  # the number of cycles or words remains the stop condition.
  # The sentences are looped
  # through in order, but once the stop condition is reached, the loop
  # ends even if all sentences are not used. Likewise, if the end of the
  # available sentences is reached before the stop condition, then it
  # selects sentences starting at index 0. If desired, this behavior
  # may in theory be changed in the future, but it is difficult to
  # anticipate what users will desire, so for now it is defined as above.
  # NOTE: If a *catalog* of sentences is given with the "order" parameter
  # (as opposed to a list of sentences), then
  # it cycles through the indices of the catalog sequentionally,
  # and an individual sentence is picked at random from the list at
  # that particular known index.
  # the previous sentence is normally excluded from the selection parameters
  # however; this is not always possible (e.g. a single item list of sentences)
  # The standard_write function handles that.
  new_state = curr_state.clone
  writepars = remove_first_word(cmdhash[:comline])
  writepars_arr = writepars.split
  # we expect 2 - 4 parameters
  if (writepars_arr.size < 2) or (writepars_arr.size > 4) then
    # ERR_ID FENNEL
    stop_with_par_num_error.call("WRITE", cmdhash[:linenum], cmdhash[:comline], "2 - 4 parameters", writepars_arr.size.to_s)
  end
  sentence_varname = writepars_arr[0].strip.downcase
  word_varname = writepars_arr[1].strip.downcase
  # check if words and sentence varname exist
  sentence_info = access_value(sentence_varname, new_state)
  word_info = access_value(word_varname, new_state)
  if (word_info[:exists] == false) or (word_info[:value].empty? == true) then
    # ERR_ID GARBANZO
    stop_with_general_command_error("The specified word variable does not exist or is empty", "WRITE", cmdhash[:linenum], cmdhash[:comline], "a valid word variable name", word_varname)
  end
  if (sentence_info[:exists] == false) or (sentence_info[:value].empty? == true) or (sentence_info[:value] == [""]) then
    # note that this only triggers if the sentence is an empty list, but if
    # it's a catalog containing an empty list, error won't trigger - that
    # situation is handled elsewhere.
    # ERR_ID GARLIC
    if sentence_info[:exists] == false then
      problem = "does not exist"
    else
      problem = "is empty"
    end
    stop_with_general_command_error("The specified sentence variable " + problem, "WRITE", cmdhash[:linenum], cmdhash[:comline], "a valid and non-empty sentence variable name", sentence_varname)
  end
  # need to do typechecking
  if (sentence_info[:unit_type] != :catalog) and (sentence_info[:unit_type] != :list) then
    # ERR_ID GINGER
    stop_with_general_command_error("The specified sentence variable #{sentence_varname} is of the wrong type", "WRITE", cmdhash[:linenum], cmdhash[:comline], "a variable of type list or catalog")
  end
  if word_info[:unit_type] != :catalog then
    # ERR_ID GREENBEAN
    stop_with_general_command_error("The specified word variable #{word_varname} is of the wrong type", "WRITE", cmdhash[:linenum], cmdhash[:comline], "a variable of type catalog")
  end
  # typechecking is done, now see if we have any other parameters
  if writepars_arr.size > 2 then
    # need to get the amount, otherwise default to 1
    amount_str = writepars_arr[2].strip
    if valid_int?(amount_str) or valid_num_range?(amount_str) then
      amount = resolve_num_or_numrange(amount_str)
      style = :cycle
    elsif valid_word_num?(amount_str) then
      amount = amount_str.to_i + word_count_arr(new_state["story_so_far"])
      style = :word
    elsif valid_word_range?(amount_str) then
      amount = resolve_word_range(amount_str) + word_count_arr(new_state["story_so_far"])
      style = :word
    else
      # ERR_ID GUAR
      stop_with_general_command_error("Syntax error in requested number", "WRITE", cmdhash[:linenum], cmdhash[:comline], "a number or numerical range, or an amount of words or numerical range of words", amount_str)
    end
    if writepars_arr.size > 3 then
      # see if we have random or order
      ordering = writepars_arr[3].strip.downcase
      if (ordering != "random") and (ordering != "order") then
        # ERR_ID HORSERADISH
        stop_with_general_command_error("Syntax error in the ordering parameter", "WRITE", cmdhash[:linenum], cmdhash[:comline], "RANDOM or ORDER", ordering)
      end
    else
      ordering = "random"
    end
  else
    amount = 1
    style = :cycle
  end
  if sentence_info[:value].class == Hash then
    sentence_value = sentence_info[:value].to_a
  else
    sentence_value = sentence_info[:value]
  end
  # we now have all the needed parameters and can proceed with calling
  # the function that generates the sentence, wordsubs it, adds to
  # state, and repeats the appropriate number of times
  if ordering == "order" then
    start_ind = 0
  else
    # random ordering; pick a random index
    uplim = sentence_value.size - 1
    start_ind = rand(0..uplim)
  end
  new_state = standard_write(new_state, sentence_value, word_info[:value], ordering, 0, amount, style, start_ind)
  return new_state
end

def special_write(curr_state, cmdhash, cmdname, sentence_str, format_str)
  # This function returns the current state after writing special commands
  # to the story (e.g. newline, newpara, newchapter). It does this by
  # calling format_sentence with the appropriate special sentence and
  # formatting to fit the desired result (i.e. not the user-specified
  # FORMAT parameters). The formatted sentence is added to the story.
  # cmdhash and cmdname are present for error reporting purposes only. 
  new_state = curr_state.clone
  theline = cmdhash[:comline].strip
  if theline.split.size != 1 then
    # ERR_ID KALE
    stop_with_general_command_error("Command takes no parameters", cmdname.upcase, cmdhash[:linenum], cmdhash[:comline])
  end
  # add the line
  formatted_sentence = format_str.chars.reduce(sentence_str){|changing_s, char|
    format_sentence(changing_s, char, curr_state)}
  new_state["story_so_far"] << formatted_sentence
  return new_state
end

def newline(curr_state, cmdhash)
  # adds a new blank line into the story so far and returns new state
  special_write(curr_state, cmdhash, "NEWLINE", " ", "Y")
end

def newpara(curr_state, cmdhash)
  # adds a paragraph break into the story so far and returns new state
  special_write(curr_state, cmdhash, "NEWPARA", " ", "Z")
end

def newchapter(curr_state, cmdhash)
  # inserts a chapter heading into the story so far and increments the
  # chapter counter, returning the new state
  new_chapter_num = curr_state["chapter"] + 1
  the_sentence = "Chapter " + new_chapter_num.to_s
  curr_state["chapter"] = new_chapter_num
  special_write(curr_state, cmdhash, "NEWCHAPTER", the_sentence, "F")
end

def format(curr_state, cmdhash)
  # Returns story state with formatting parameter string setting
  # updated to the user-supplied formatting string.
  # Default starter format is "ACPS" (a/an, capitalize first letter,
  # append period, append space). Each formatting letter code will be
  # applied to every subsequent sentence in the write command. Formatting
  # is applied in the order given in the user-supplied format string; so
  # for CPS the capitalization is applied first, then the period at the
  # end, then the space at the end. It is up to the user to ensure
  # the desired order of their format string.
  excluded_letterset = "ORUVW".chars.to_set
  allowableset = ('A'..'Z').to_set - excluded_letterset
  par = remove_first_word(cmdhash[:comline]).strip.upcase
  if par.split.size !=1 then
    # ERR_ID LEEK
    stop_with_par_num_error.call("FORMAT", cmdhash[:linenum], cmdhash[:comline], "1 string parameter", "#{par.split.size.to_s} parameters")
  end
  parset = par.chars.to_set
  leftover = parset - allowableset
  if leftover.empty? == false then
    leftarr = leftover.to_a
    # ERR_ID LEMONGRASS
    stop_with_general_command_error("You have these invalid letter codes: #{leftarr}", "FORMAT", cmdhash[:linenum], cmdhash[:comline])
  end
  curr_state["format"] = par
  return curr_state
end

def file_2_arr(filename, remove_blanks = false)
  # Given a filename within this working directory, this will return an array
  # with each line of the file as an item of the array.
  # Items are purposely not unique here; if unique is desired this
  # must be done afterwards (using Ruby's uniq method)
  arrname = Array.new
  if File.exists?(filename) then
    IO.foreach(filename){|theline|
      if remove_blanks == false then
        arrname << theline.chomp.strip
      else
        # need to remove blank lines
        if theline.chomp.strip.empty? == false
          arrname << theline.chomp.strip
        end
      end
    }
  else
    # ERR_ID LENTIL
    stop_with_general_command_error("File error - #{filename} not found", "an internal file", "program as a whole", "while reading files")
  end
  return arrname
end

def access_value(varname, curr_state, style = :all, mode = :lookup, newvalue = nil)
  # If mode is :lookup, this acts in a read-only, lookup mode. In
  # that case, given a varname and the story state, returns a hash describing
  # whether the var :exists (t/f) :unit_type (:list, :catalog, :single, or
  # :genall) and :value (value or nil) The style parameter may be :desc,
  # :words, :sentences, :gen, or :uvar.
  #
  # If mode is :change then this function acts as a way to update existing
  # values only, and in this situation the new story state is returned instead
  # of the hash that is given in lookup mode. The newvalue MUST be non-nil
  # (but may be an empty value) for any update to occur. It is not the
  # responsibility of this function to check for type matching when
  # setting the new value, it is expected that this would be done prior.
  thevar = varname.strip.downcase
  new_state = curr_state.clone
  result = Hash.new
  result[:exists] = false
  result[:unit_type] = nil
  result[:value] = nil
  # DESC
  if style == :desc then
    if curr_state["user_descs"].include?(thevar) then
      result[:exists] = true
      result[:value] = curr_state["user_descs"][thevar]
      if result[:value].class == Array then
        result[:unit_type] = :list
      # for future_work - catalogs of descs; not being used at the moment
      elsif result[:value].class == Hash then
        result[:unit_type] = :catalog
      end
    end
    if mode == :change and newvalue != nil then
      new_state["user_descs"][thevar] = newvalue
    end
  end
  if (style == :all) or (style == :words) then
    if curr_state["words"].include?(thevar) then
      result[:exists] = true
      result[:unit_type] = :list
      result[:value] = curr_state["words"][thevar]
      if mode == :change and newvalue != nil then
        new_state["words"][thevar] = newvalue
      end
    end
  end
  if ((style == :all) and result[:value] == nil) or (style == :sentences) then
    if curr_state["sentences"].include?(thevar) then
      result[:exists] = true
      result[:unit_type] = :list
      result[:value] = curr_state["sentences"][thevar]
      if mode ==:change and newvalue != nil then
        new_state["sentences"][thevar] = newvalue
      end
    end
  end
  if ((style == :all) and result[:value] == nil) or (style == :gen) then
    if contains_period?(thevar) == false then
      if curr_state["user_gens"].include?(thevar) then
        result[:exists] = true
        result[:unit_type] = :genall
        result[:value] = curr_state["user_gens"][thevar]
        if mode == :change and newvalue != nil then
          # need to re-assign curr gen before assigning new value
          # locate curr gen
          curr_gen_id = curr_state["curr_gens"][thevar]
          curr_gen = curr_state["user_gens"][thevar][curr_gen_id]
          # re-assign curr gen to previously current one if
          # possible, otherwise set to 0
          new_state["user_gens"][thevar] = newvalue
          new_index = new_state["user_gens"][thevar].index(curr_gen)
          if new_index != nil then
            new_state["curr_gens"][thevar] = new_index
          else
            new_state["curr_gens"][thevar] = 0
          end
        end
      end
    else
      splitted = thevar.split(".")
      if curr_state["user_gens"].include?(splitted[0]) then
        result[:exists] = true
        result[:unit_type] = :list
        curr_gen_id = curr_state["curr_gens"][splitted[0]]
        curr_gen = curr_state["user_gens"][splitted[0]][curr_gen_id]
        # need to allocate nil value if the gen is empty
        if curr_gen == nil then
          result[:exists] = false
          result[:unit_type] = nil
          result[:value] = nil
        elsif curr_gen.include?(splitted[1]) then
          result[:value] = curr_gen[splitted[1]]
          if (mode == :change) and (newvalue != nil) then
            new_state["user_gens"][splitted[0]][curr_gen_id][splitted[1]] = newvalue
            
          end
        else
          result[:exists] = false
          result[:unit_type] = nil
          result[:value] = nil
        end
      end
    end
  end
  if ((style == :all) and result[:value] == nil) or (style == :uvar) then
    if curr_state["user_vars"].include?(thevar) then
      result[:exists] = true
      result[:value] = curr_state["user_vars"][thevar]
      if result[:value].class == String then
        result[:unit_type] = :single
      elsif result[:value].class == Hash then
        result[:unit_type] = :catalog
      else
        result[:unit_type] = :list
      end
      if (mode == :change) and (newvalue != nil) then
        new_state["user_vars"][thevar] = newvalue
        
      end
    end
  end
  if mode == :lookup then
    return result
  else
    return new_state
  end
end

def access_gen_item_all(varname, curr_state)
  # Given the varname of a gen list (i.e. varname contains a period),
  # returns a list containing the item across all individual gens of that
  # name. Typically called by the recite function when seeking
  # to recite all names in a gen, for example.
  result = Array.new
  desired_var = varname.strip.downcase
  command = get_command(curr_state["curr_line"][:comline])
  splitted = split_l_r(desired_var, ".")
  if splitted[:error] != 0 then
    # ERR_ID YARROW
    stop_with_general_command_error("Expecting a variable of a gen item", command, curr_state["curr_line"][:linenum], curr_state["curr_line"][:comline], "a variable of format something.somethingelse", desired_var)
  end
  whole_gen = access_value(splitted[:l], curr_state, :gen)
  if (whole_gen[:exists] == false) or (whole_gen[:value] == nil) then
    # ERR_ID ZUCCHINI
    stop_with_general_command_error("The gen #{splitted[:l]} either does not exist or is empty", command, curr_state["curr_line"][:linenum], curr_state["curr_line"][:comline])
  end
  # we have the whole gen, now get the value of each items and add into a list
  whole_gen[:value].each{|one|
    if one.include?(splitted[:r]) then
      result = result + one[splitted[:r]]
    end}
  return result
end

def get_subcat_value(match_key, wordhash)
  # Given a hash (typically one representing a catalog), returns the value
  # of the desired key (match_key) in the same format as for the function
  # access_value, i.e. a hash with the keys :exists, :unit_type, :value
  result = Hash.new
  desired_key = match_key.downcase
  if (wordhash == nil) or (wordhash.include?(desired_key) == false) then
    result[:exists] = false
    result[:unit_type] = nil
    result[:value] = nil
  else
    result[:exists] = true
    result[:value] = wordhash[desired_key]
    if result[:value].class == Array then
      result[:unit_type] = :list
    elsif result[:value].class == String then
      result[:unit_type] = :single
    elsif result[:value].class = Hash then
      result[:unit_type] = :catalog
    else
      result[:unit_type] = nil
    end
  end
  return result
end

def grab(pattmatch)
  # Given the pattern to match a particular directory within the working
  # directory of this program, returns a hash containing the contents of each
  # file within. It identifies the first directory that matches the
  # naming pattern, case-insensitive, and then finds all the files in
  # that directory and reads then into the returned hash. This hash is
  # indexed by filenames (minus extensions). The contents of each indexed
  # item is an array of each line of the file. If no matching directory is
  # found, or if no files exist within the directory, an empty hash is returned.
  result = Hash.new
  found_dirs = Dir.glob(pattmatch, File::FNM_CASEFOLD)
  if found_dirs.empty? == false then
    main_dir = found_dirs[0]
    # test if it's a directory; if so get items
    if File.directory?(main_dir) then
      Dir.each_child(main_dir){|filename|
        pname = main_dir + "/" + filename
        if File.file?(pname) and (File.zero?(pname) == false) then
          # need to to open filename
          lexer_puts("Reading file #{filename}")
          temparr = file_2_arr(pname, true).uniq
          # index of hash is filename without extension
          index = filename.sub(/\..*$/, "").downcase
          result[index] = temparr
        else
          # WARN_ID BLUEBERRY
          mild_warning.call("Item: #{filename} in directory #{main_dir} is not a file or is an empty file - ignoring")
        end
      }
    end
  else
    # WARN_ID BOYSENBERRY
    severe_warning.call("No directory found for words or sentences matching #{pattmatch}")
  end
  return result
end

def gen_ptr_value(curr_state, gen_name, mode = :numerical)
  # Given a gen name and the current state, and if mode is :numerical,
  # returns the numerical value of the gen ptr, i.e. the index of
  # the currently active gen item. If the gen name does not exist,
  # OR the gen ptr is out of bounds, then returns nil
  # If mode is :item it returns the current item of the current gen. If the
  # gen ptr for it is invalid then it returns nil, as for other mode.
  gen_id = gen_name.strip.downcase
  if curr_state["curr_gens"].include?(gen_id) then
    the_num = curr_state["curr_gens"][gen_id]
    if (the_num != nil) and (the_num >= 0 ) and (the_num <= curr_state["user_gens"][gen_id].size - 1) then
      if mode == :numerical then
        return the_num
      else
        # return what it's pointing to
        return curr_state["user_gens"][gen_id][the_num]
      end
    else
      return nil
    end
  else
    return nil
  end
end

def gen_item_value(curr_state, gen_name, gen_item)
  # Given a gen item value (gen_item) of gen_name, returns the numerical
  # pointer value (i.e. by determining its index). If the gen_item is
  # not found within gen_name, returns nil. Note that if gen_item has been
  # altered compared to the version stored in gen_name, it will be therefore
  # considered different and nil will be returned.
  gen_id = gen_name.strip.downcase
  if curr_state["user_gens"][gen_id].include?(gen_item) then
    curr_state["user_gens"][gen_id].index(gen_item)
  else
    nil
  end
end

def shift(curr_state, cmdhash)
  # Returns the new state after shifting the current item
  # the specified number of places in the gen array referred to in cmdhash.
  # e.g SHIFT varname -2
  # Numbers do not overflow; they merely cycle around. Thus, only the
  # pointer for that gen is altered, not the gen itself.
  # shift is only designed to work for gens at the moment, although
  # that is something that could in theory be changed to other types of
  # user variables in the future.
  new_state = curr_state.clone
  pars = remove_first_word(cmdhash[:comline].strip.downcase)
  par_arr = pars.split
  if (par_arr.size > 2) or (par_arr.size < 1) then
    # ERR_ID LETTUCE
    stop_with_par_num_error.call("SHIFT", cmdhash[:linenum], cmdhash[:comline], "1 or 2 parameters", par_arr.size.to_s)
  end
  gen_name = par_arr[0].strip
  if par_arr.size == 2 then
    shift_str = par_arr[1].strip
    # stop if it's not a proper number or is zero. Remember that
    # "-55c".to_i = -55. So we need to check via pattern matching instead.
    if (shift_str.match?(/^[\-]*[[:digit:]]+/) == false) or (shift_str.to_i == 0) then
      # ERR_ID LIMABEAN
      stop_with_syntax_error.call("SHIFT", cmdhash[:linenum], cmdhash[:comline], "a non-zero numerical parameter", shift_str)
    end
  else
    shift_str = "1"
  end
  shift_num = shift_str.to_i
  if contains_period?(gen_name) then
    # ERR_ID MANGETOUT
    stop_with_syntax_error.call("SHIFT", cmdhash[:linenum], cmdhash[:comline], "a gen", "a variable inside a gen") 
  end
  # check if variable exists as a gen
  gen_info = access_value(gen_name.downcase, curr_state, :gen)
  if gen_info[:exists] == false then
    # ERR_ID MUNGBEAN
    stop_with_unknown_variable_error(gen_name).call("SHIFT", cmdhash[:linenum], cmdhash[:comline], "a variable which is a gen", "an unknown variable, or a variable that is not a gen")
  end
  ptr_num = gen_ptr_value(curr_state, gen_name.downcase)
  if gen_info[:value].empty? or ptr_num == nil then
    # WARN_ID BREADFRUIT
    severe_warning.call("Referenced gen #{gen_name} is empty or the current one has a nil value. This may indicate that there are no items in this gen", "SHIFT", cmdhash[:linenum], cmdhash[:comline])
  else
    # determine its size and access the gen pointer
    gen_size = gen_info[:value].size
    # the ptr has a valid numeric value, we want to shift it by a valid amount
    ptr_val = ptr_num.to_i
    # this will work for positive or negative values of shift
    new_ptr_val = (ptr_val + shift_num) % gen_size
    new_state["curr_gens"][gen_name.downcase] = new_ptr_val
  end
  return new_state
end

def shuffle(curr_state, cmdhash)
  # Returns the new state after randomly shuffling the
  # gen array referred to in cmdhash. The gen pointer will be changed
  # to the item it was originally pointing to, so it can continue to stay
  # on the same item; thus both the gen and the value of the gen pointer
  # are changed. NOTE: shuffle does not force a rearrangement, so small
  # arrays have a random chance of coming back in the same order they
  # started in - this is particularly likely for arrays of size 2.
  # arrays of size 1 or 0 are returned unchanged.
  new_state = curr_state.clone
  pars = remove_first_word(cmdhash[:comline].strip.downcase)
  par_arr = pars.split
  if par_arr.size != 1 then
    # ERR_ID MUSHROOM
    stop_with_par_num_error.call("SHUFFLE", cmdhash[:linenum], cmdhash[:comline], "1 parameter", par_arr.size.to_s)
  end
  # at this point we have a par, need to check if it corresponds to a gen
  gen_name = par_arr[0].strip.downcase
  if contains_period?(gen_name) then
    # ERR_ID MUSTARDGREEN
    stop_with_syntax_error.call("SHUFFLE", cmdhash[:linenum], cmdhash[:comline], "a gen", "a variable inside a gen")
  end
  gen_info = access_value(gen_name, curr_state, :gen)
  if gen_info[:exists] == false then
    # ERR_ID OKRA
    stop_with_unknown_variable_error(gen_name).call("SHUFFLE", cmdhash[:linenum], cmdhash[:comline], "a gen variable", "an unknown variable or one that is not a gen")
  end
  # we have an existing gen, which if it has a size of 0 or 1, we don't want
  # to shuffle
  if gen_info[:value].size > 1 then
    # get current item
    curr_item = gen_ptr_value(curr_state, gen_name, :item)
    # shuffle
    shuffled = gen_info[:value].shuffle
    new_state["user_gens"][gen_name] = shuffled
    # determine new ptr value
    new_ptr_val = gen_item_value(new_state, gen_name, curr_item)
    # assign new ptr value
    new_state["curr_gens"][gen_name] = new_ptr_val
  end
  return new_state
end

def one_sentence_suball(sentence, curr_state, word_hash_arrs = curr_state["words"], fallback = "SOMETHING", stdmatch = /_[[:alnum:]]+[\.]*[[:alnum:]]*_/)
  # Given a sentence (sentence) which may or may not contain
  # substitution pattern(s) in stdmatch e.g. _NOUN_  If such a pattern is
  # present this function will substitute a word from whichever hash key
  # in the word list (word_hash_arrs) matches the substitution pattern
  # without the outer two characters.
  # This process is repeated until all substitutions within the sentence
  # have been made. The resultant fully substituted sentence is returned.
  #
  # If no word is found that matches the requested substitution pattern,
  # the fallback of "SOMETHING" is substituted instead. We do need to
  # at least make some change to each substitution pattern in the
  # sentence via the fallback, otherwise will wind up in endless loop.
  # The function stops once all matches have been substituted.
  if sentence.match?(stdmatch) == false then
    sentence
  else
    # we have a match
    matchword = sentence.match(stdmatch)[0]
    # NOTE: if stdmatch is to vary from the default, the following line(s) may
    # need to be changed.
    matchkey = matchword[1..-2].downcase
    if contains_period?(matchkey) == true then
      # it's a gen
      returned_value = access_value(matchkey, curr_state, :gen)
    else
      # it's a word that we should expect to find in word_hash_arrs
      returned_value = get_subcat_value(matchkey, word_hash_arrs)
    end
    if returned_value[:exists] == true then
      # the key exists
      if (returned_value[:value] != nil) and (returned_value[:value].empty? == false) and (returned_value[:unit_type] == :list) then
        # the requested substitution may proceed
        desired_sub = select_random_one.call(returned_value[:value])[0]
      else
        # warning in case array hash is pointing to is empty
        # WARN_ID CHERRY
        severe_warning.call("Unable to complete word substitution for: #{matchword} - wordset: #{matchkey} either does not exist within the word catalog variable you specified (even though you may have defined it elsewhere in the program), or exists but is empty, or is not a collection of words", "WRITE", curr_state["curr_line"][:linenum], curr_state["curr_line"][:comline])
        desired_sub = fallback
      end
    else
      # there is a requested sub, but no key of that name in words
      # WARN_ID CRANBERRY
      severe_warning.call("Attempting to substitute but the word set #{matchkey} does not exist in the word catalog variable you specified (even though you may have defined it elsewhere in the program): ", "WRITE", curr_state["curr_line"][:linenum], curr_state["curr_line"][:comline])
      desired_sub = fallback
    end
    # replace remaining instances in sentence
    new_sentence = sentence.sub(stdmatch, desired_sub)
    one_sentence_suball(new_sentence, curr_state, word_hash_arrs)
  end
end

def get_loop_pars(curr_state, cmdhash)
  # This is the parser for the loop comand, which retrieves loop parameters.
  # Given the command hash containing a LOOP command and the current
  # story state, returns the loop parameters as a hash. Loop parameters
  # are: the type of loop (cycle or word) and the requested number,
  # including resolving any requested random numbers to a single number.
  # Will halt with error if user enters too many parameters or unrecognizable
  # parameters.
  # Called by loop_iterator.
  correct_usage = "\n LOOP 5 \n LOOP 4--10 \n LOOP 500W \n LOOP 600W--900W"
  user_cmd = "LOOP"
  loopcmds = cmdhash[:comline].split
  # have splitted on space
  if loopcmds.size == 1 then
    # we have a LOOP command by itself, which defaults to LOOP 1
    loop_pars = {num: 1, style: :cycle}
  elsif loopcmds.size > 2 then
    # we have too many parameters
    # ERR_ID ONION
    stop_with_par_num_error.call(user_cmd, cmdhash[:linenum], cmdhash[:comline], correct_usage, "too many parameters")
  elsif valid_word_range?(loopcmds[1]) then
    user_range = word_range(loopcmds[1])
    resolve_random = rand(user_range[0]..user_range[1])
    loop_pars = {num: resolve_random, style: :word}
  elsif valid_word_num?(loopcmds[1]) then
    resolve = loopcmds[1].to_i
    loop_pars = {num: resolve, style: :word}
  elsif valid_num_range?(loopcmds[1]) or valid_int?(loopcmds[1]) then
    resolve = resolve_num_or_numrange(loopcmds[1])
    loop_pars = {num: resolve, style: :cycle}
  elsif access_value(loopcmds[1].downcase.strip, curr_state)[:exists] == true then
    # future_work the following capability is for future usage - not currently
    # using integer vars, so this part isn't currently used.
    if valid_int?(curr_state["user_vars"][loopcmds[1]]) then
      # ...and it's a valid integer
      resolve = curr_state["user_vars"][loopcmds[1]].to_i
      loop_pars = {num: resolve, style: :cycle}
    else
      # ERR_ID PARSNIP
      stop_with_general_command_error("The variable you referenced does not correspond to an integer", user_cmd, cmdhash[:linenum], cmdhash[:comline])
    end
  else
    # ERR_ID POTATO
    stop_with_syntax_error.call(user_cmd, cmdhash[:linenum], cmdhash[:comline], correct_usage)
  end
  return loop_pars
end

def send_to_parser(curr_state, cmdhash)
  # Given the current story state and a command, sends those to the appropriate
  # parser for each command, returning the new state. It is each command
  # parser's job to run the command and return the updated state or, if
  # there is a syntax error in user-supplied command, to halt with a description
  # of at which line it got stuck.
  # If the cmdhash argument here does not correspond to any
  # existing parser function, then this function itself will halt with a
  # description of the problem. Note that the LOOP command is handled separately
  # using another function.
  allowable_commands = Set[:refgender, :recite, :display, :newchapter, :newpara, :newline, :format, :write, :assigngen, :assignlist, :assigncatalog, :shuffle, :shift, :wordjoin, :upcase, :lowcase, :supcase, :slowcase, :call]
  if cmdhash[:comline] != "" then
    requested_command = cmdhash[:comline].split[0].downcase.to_sym
    if allowable_commands.include?(requested_command) then
      send(requested_command, curr_state, cmdhash)
    else
      # either it's a comment or an unrecognized command
      if (cmdhash[:comline].strip[0] != "#") and (cmdhash[:comline].strip.upcase.start_with?("LOOP") == false) then
        # error - unrecognized command
        # ERR_ID PUMPKIN
        stop_with_general_command_error("Unrecognized command", "", cmdhash[:linenum].to_s, cmdhash[:comline])
      end
    end
  end
  return curr_state
end

def progarr_2_hasharr(progarr)
  # Given the array of the raw command list written by the user,
  # returns an array of hashes, where :linenum is the user program's
  # line number, and :comline is the raw user command
  hasharr = Array.new
  progarr.each_with_index{|item, index|
    currhash = {linenum: index + 1, comline: item}
    hasharr << currhash
  }
  return hasharr
end

def hasharr_2_chunkarr(hasharr)
  # Given the hashed command list hasharr (the one returned by
  # progarr_2_hasharr) returns chunked (grouped) sub-arrays of commands
  # where ordinary consecutive commands are chunked together, and looping-style
  # start and end commands remain separate. This function does not change
  # the ORDER of the hash items, merely the grouping. This array only has
  # 1 extra level of nesting, and all items are at this same level. This
  # function is a precursor to the conversion to an array with multiple
  # levels of nesting to reflect the structure of the user program.
  hasharr.chunk_while{|first, second| (is_start?(second[:comline]) == false) and (is_start?(first[:comline]) == false) and (is_end?(first[:comline]) == false) and (is_end?(second[:comline]) == false)}.to_a
end

def chunkarr_2_nestedprogarr(chunkarr)
  # Given a grouped array of hashes of program commands chunkarr  (i.e. that
  # produced by hasharr_2_chunkarr), returns this array of hashes in a
  # nested form reflecting the program structure.
  # In other words, an array containing the same total number of elements
  # is returned, but nested differently.
  currstack = Array.new
  currstack << ["INIT"]
  chunkarr.each{|item|
    if is_start?(item[0][:comline]) then
      currstack.last << item
      currstack.push(item)
    elsif is_end?(item[0][:comline]) then
      currstack.last.concat(item)
      # check here that we are not popping under
      if currstack.size > 1 then
        currstack.pop
      else
        # ERR_ID RADISH
        stop_with_general_command_error("Too many END-style commands e.g. LOOPEND, GENEND, etc reached", "", item[0][:linenum], item[0][:comline])
      end
    else
      # the item is a series of commands
      currstack.last.concat(item)
    end}
  if currstack.size > 1 then
    extra_starts = (currstack.size - 1).to_s
    # ERR_ID REDLETTUCE
    stop_with_general_command_error("Insufficient END-style commands (e.g. LOOPEND, GENEND, etc) compared to start-style commands", "LOOP or GEN", "your program as a whole", "your loop structures as a whole", "an equal amount of start-style commands and end-style commends", "#{extra_starts} extra starts or missing ends in your program")
  end
  return currstack[0].drop(1)
end

def loop_iterator(curr_state, nested_commands, curr_condition, stop_condition, change_style)
  # Returns the new state of the story. This function goes through the
  # nested commands and either performs the requested command (by sending
  # it to the parser), or if the command is itself an array of
  # commands (i.e. a loop) then it will recursively go through and perform that
  # array of commands, and so on. Remember that the entire program is
  # a set of nested commands. The parameters the function takes are the current
  # state, a set of commands (which may have nested sublevels), the
  # current condition and stop condition, which are represented
  # numerically, and change_style which may be :cycle or :word, depending
  # whether the target is a certain number of cycles or a certain
  # number of words.
  # This function is responsible for parsing and executing the requested
  # quantity of repeats and stopping when the stop condition is satisfied.
  if change_style == :cycle then
    new_curr = curr_condition + 1
  else
    # change_style == :word
    new_curr = word_count_arr(curr_state["story_so_far"])
  end
  if curr_condition >= stop_condition then
    return curr_state
  end
  if (stop_condition - curr_condition) > 10000 then
    # give user feedback to know that the program is still running
    print "."
  end
  nested_commands.each{|command_item|
    if command_item.class == Hash then
      # it's a single command
      curr_state["curr_line"] = command_item
      curr_state = send_to_parser(curr_state, command_item)
    else
      # The command is itself an array so we need to loop through that
      # Take a look at the first item of that command to set up the
      # loop conditions properly, including any random numbers specified
      first_item = command_item[0]
      curr_state["curr_line"] = first_item
      # we can be confident that first_item is not itself an array.
      # this is because an array will start a LOOP command hash, even if
      # this is part of nested loops.
      # at this point it is a GEN, DESC, or LOOP.
      if first_item[:comline].strip.upcase == "GEN" or first_word(first_item[:comline]).strip.upcase == "GEN" then
        # need to pass this section to gen function
        curr_state = gen_user_structure(curr_state, command_item)
      # DESC
      elsif first_item[:comline].strip.upcase == "DESC" or first_word(first_item[:comline]).strip.upcase == "DESC" then
        # need to pass this section to store_desc function
        curr_state = store_desc(curr_state, command_item)
      else
        # it's a LOOP statement
        pars = get_loop_pars(curr_state, first_item)
        # need to handle increments differently depending on style
        # if words, calc current words, then stop cond is the desired wordnum
        # added to that total.  If cycles, start at 0 and stop at desired num
        if pars[:style] == :word then
          # need to calc current and desired word numbers
          next_curr = word_count_arr(curr_state["story_so_far"])
          #       next_stop = curr_condition + pars[:num]
          next_stop = next_curr + pars[:num]
        else
          # cycles
          next_curr = 0
          next_stop = pars[:num]
        end
        curr_state = loop_iterator(curr_state, command_item, next_curr, next_stop, pars[:style])
      end
    end
  }
  # having gotten to the end of the commands, repeat them as needed
  # in the case of words, the word count may have changed between the
  # start of the function and now
  if change_style == :word then
    new_curr = word_count_arr(curr_state["story_so_far"])
  end
  curr_state = loop_iterator(curr_state, nested_commands, new_curr, stop_condition, change_style)
end

######################################
########## BODY OF PROGRAM ###########
######################################

### DEFINE IMPORTANT VARIABLES AND DEFAULTS BEFORE STARTING LEXER ###

default_male_names = ["Lionel", "Alfred", "Lennon", "Theo", "Mervyn", "Trystan", "Antwan", "Ross", "Leroy", "Nigel", "Darien", "Keon", "Vaughn"]
default_female_names = ["Ann", "Kayleen", "Marianna", "Roselyn", "Alisa", "Nathalia", "Mylee", "Theresa", "Damaris", "Audriana", "Carina", "Pearl", "Mina"]
default_nonbinary_names = ["Verv", "Stanter", "Ilme", "Apri", "Canter", "Elm", "Valor", "Rallyum", "Rune", "Umbra", "Vio", "Xap", "Zylith"]
default_robot_names = ["Splasher", "Sprocket", "Gear", "Equilateral", "Solver", "Cruncher", "Isosceles", "Lambda", "Divisor", "Calculus", "Enumerator", "Sensor", "Denominator"]

fname = ARGV[0]
lexer_puts "WELCOME :)"
lexer_puts "Running your program..."
gender_info = Hash.new
male_pronouns = {"heshe"=> "he", "himher"=> "him", "hisher"=> "his", "manwoman"=>"man", "waswere"=>"was", "isare"=>"is"}
female_pronouns = {"heshe" => "she", "himher" => "her", "hisher" => "her", "manwoman"=>"woman", "waswere"=>"was", "isare"=>"is"}
nonbinary_pronouns = {"heshe"=> "they", "himher"=> "them", "hisher"=> "their", "manwoman"=>"person", "waswere"=>"were", "isare"=>"are"}
robot_pronouns = {"heshe"=> "it", "himher"=> "it", "hisher"=> "its", "manwoman"=>"robot", "waswere"=>"was", "isare"=>"is"}
gender_info["female"] = {"names" => default_female_names, "pronouns" => female_pronouns}
gender_info["nonbinary"] = {"names"=> default_nonbinary_names, "pronouns"=> nonbinary_pronouns}
gender_info["robot"] = {"names"=> default_robot_names, "pronouns"=> robot_pronouns}
gender_info["male"] = {"names"=> default_male_names, "pronouns"=> male_pronouns}
# gender sets in array form
gender_info[:male] = ["male"]
gender_info[:female] = ["female"]
gender_info[:nonbinary] = ["nonbinary"]
gender_info[:robot] = ["robot"]
gender_info[:binary] = ["female", "male"]
gender_info[:human] = ["female", "male", "nonbinary"]
gender_info[:all] = ["female", "male", "nonbinary", "robot"]
# set up default state
story_state = Hash.new
story_state["gender_info"] = gender_info
story_state["format"] = "ACPS"
starting_ch_num = 0
story_state["chapter"] = starting_ch_num
story_state["sentences"] = Hash.new
story_state["sentences"] = grab("sentence*")
story_state["words"] = Hash.new
story_state["words"] = grab("word*")
story_state["user_vars"] = Hash.new
story_state["user_vars"]["wfolder"] = story_state["words"]
story_state["user_vars"]["sfolder"] = story_state["sentences"]
story_state["curr_gens"] = Hash.new
story_state["user_gens"] = Hash.new
story_state["user_descs"] = Hash.new
story_state["curr_line"] = Hash.new
story_state["story_so_far"] = Array.new

############# START LEXER ################
raw_commands = file_2_arr(fname)
hasharr = progarr_2_hasharr(raw_commands)
chunkarr = hasharr_2_chunkarr(hasharr)
nested_commands = chunkarr_2_nestedprogarr(chunkarr)
new_state = loop_iterator(story_state, nested_commands, 0, 1, :cycle)

### send completed story to file output ###
if new_state["story_so_far"][0] == nil then
  story_begin = "STORY"
else
  story_begin = new_state["story_so_far"][0].strip
end
story_begin_arr = story_begin.chars
proposed_fname = ""
story_begin_arr.each{|ch|
  if ch.match?(/[[:alpha:]]/) then
    proposed_fname.concat(ch)
  end
}
if proposed_fname.size <= 9 then
  final_proposed_fname = proposed_fname + "_" + rand(1000..9999).to_s + ".md"
else
  final_proposed_fname = proposed_fname[0..8] + "_" + rand(1000..9999).to_s + ".md"
end
if final_proposed_fname == "" then
  final_proposed_fname = "YourStory_" + rand(1000..9999).to_s + ".md"
end
print "\n"
lexer_puts "About to write to file."
if File.exists?(final_proposed_fname) then
  print "Enter filename for story: "
  final_filename = gets.chomp
  if final_filename == "" then final_filename = final_proposed_fname end
else
  final_filename = final_proposed_fname
end
if File.exists?(final_filename) then
  abort "STOPPING: ERROR - Desired filename #{final_filename} already exists. No changes were made to it."
else
  lexer_puts("Writing #{word_count_arr(new_state["story_so_far"])} words to file: #{final_filename}")
  open(final_filename, 'w'){|out|
    new_state["story_so_far"].each{|sentence|
      out.print(sentence)}
  }
end
