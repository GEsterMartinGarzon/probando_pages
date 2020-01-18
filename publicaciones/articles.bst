% article.bst (Web)

ENTRY
  { author
%	    Name(s) of author(s), in BibTeX name format.
    title
%	    The title of the thing you're referred to.
    journal
%	    Journal name (macros are provided for many).
    year
%	    The year should contain only numerals (technically, it should end
%	    with four numerals, after purification; doesn't a begin sentence).
    key
%	    Alphabetizing, labeling, and cross-referencing key
%	    (needed when an entry has no author or editor).
    volume
%	    The volume number of a journal or multivolume work.
    number
%	    Number of a journal or technical report, or of a work in a series.
    pages
%	    Page number or numbers (use `--' to separate a range, use `+'
%	    to indicate pages following that don't form a simple range).
    month
%	    Month (macros are provided).
    note
%	    To help the reader find a reference (begins sentence).
    ISBN
    ISSN
%    quality
%    subject_categories
    url
%    doi
  }
% There are no integer entry variables
  {}
  { label }

% Each entry function starts by calling output.bibitem, to write the
% \bibitem and its arguments to the .BBL file.  Then the various fields
% are formatted and printed by output or output.check.  Those functions
% handle the writing of separators (commas, periods, \newblock's),
% taking care not to do so when they are passed a null string.
% Finally, fin.entry is called to add the final period and finish the
% entry.
%
% A bibliographic reference is formatted into a number of `blocks':
% in the open format, a block begins on a new line and subsequent
% lines of the block are indented.  A block may contain more than
% one sentence (well, not a grammatical sentence, but something to
% be ended with a sentence ending period).  The entry functions should
% call new.block whenever a block other than the first is about to be
% started.  They should call new.sentence whenever a new sentence is
% to be started.  The output functions will ensure that if two
% new.sentence's occur without any non-null string being output between
% them then there won't be two periods output.  Similarly for two
% successive new.block's.
%
% The output routines don't write their argument immediately.
% Instead, by convention, that argument is saved on the stack to be
% output next time (when we'll know what separator needs to come
% after it).  Meanwhile, the output routine has to pop the pending
% output off the stack, append any needed separator, and write it.
%
% To tell which separator is needed, we maintain an output.state.
% It will be one of these values:
%	before.all		just after the \bibitem
%	mid.sentence		in the middle of a sentence: comma needed
%					if more sentence is output
%	after.sentence		just after a sentence: period needed
%	after.block		just after a block (and sentence):
%					period and \newblock needed.
% Note: These styles don't use after.sentence
%
% VAR: output.state : INTEGER		-- state variable for output
%
% The output.nonnull function saves its argument (assumed to be nonnull)
% on the stack, and writes the old saved value followed by any needed
% separator.  The ordering of the tests is decreasing frequency of
% occurrence.
%
% output.nonnull(s) ==
%  BEGIN
%	s := argument on stack
%	if output.state = mid.sentence then
%	    write$(pop() * ", ")
%		  -- "pop" isn't a function: just use stack top
%	else
%	    if output.state = after.block then
%		write$(add.period$(pop()))
%		newline$
%		write$("\newblock ")
%	    else
%		if output.state = before.all then
%		    write$(pop())
%		else	    -- output.state should be after.sentence
%		    write$(add.period$(pop()) * " ")
%		fi
%	    fi
%	    output.state := mid.sentence
%	fi
%	push s on stack
%  END
%
% The output function calls output.nonnull if its argument is non-empty;
% its argument may be a missing field (thus, not necessarily a string)
%
% output(s) ==
%  BEGIN
%	if not empty$(s) then output.nonnull(s)
%	fi
%  END
%
% The output.check function is the same as the output function except that, if
% necessary, output.check warns the user that the t field shouldn't be empty
% (this is because it probably won't be a good reference without the field;
% the entry functions try to make the formatting look reasonable even when
% such fields are empty).
%
% output.check(s,t) ==
%  BEGIN
%	if empty$(s) then
%	    warning$("empty " * t * " in " * cite$)
%	else output.nonnull(s)
%	fi
%  END
%
% The output.bibitem function writes the \bibitem for the current entry
% (the label should already have been set up), and sets up the separator
% state for the output functions.  And, it leaves a string on the stack
% as per the output convention.
%
% output.bibitem ==
%  BEGIN
%	newline$
%	write$("\bibitem[")	% for alphabetic labels,
%	write$(label)		% these three lines
%	write$("]{")		% are used
%	write$("\bibitem{")		% this line for numeric labels
%	write$(cite$)
%	write$("}")
%	push "" on stack
%	output.state := before.all
%  END
%
% The fin.entry function finishes off an entry by adding a period to the
% string remaining on the stack.  If the state is still before.all
% then nothing was produced for this entry, so the result will look bad,
% but the user deserves it. (We don't omit the whole entry because the
% entry was cited, and a bibitem is needed to define the citation label.)
%
% fin.entry ==
%  BEGIN
%	write$(add.period$(pop()))
%	newline$
%  END
%
% The new.block function prepares for a new block to be output, and
% new.sentence prepares for a new sentence.
%
% new.block ==
%  BEGIN
%	if output.state <> before.all then
%	    output.state := after.block
%	fi
%  END
%
% new.sentence ==
%  BEGIN
%	if output.state <> after.block then
%	    if output.state <> before.all then
%		output.state :=  after.sentence
%	    fi
%	fi
%  END
%

INTEGERS { output.state before.all mid.sentence after.sentence after.block }

FUNCTION {init.state.consts}
{ #0 'before.all :=
  #1 'mid.sentence :=
  #2 'after.sentence :=
  #3 'after.block :=
}

STRINGS { s t }

FUNCTION {output.nonnull}
{ 's :=
  output.state mid.sentence =
    { ", " * write$ }
    { output.state after.block =
	{ add.period$ write$
	  newline$
	  "\newblock " write$
	}
	{ output.state before.all =
	    'write$
	    { add.period$ " " * write$ }
	  if$
	}
      if$
      mid.sentence 'output.state :=
    }
  if$
  s
}

FUNCTION {output}
{ duplicate$ empty$
    'pop$
    'output.nonnull
  if$
}

FUNCTION {output.check}
{ 't :=
  duplicate$ empty$
    { pop$ "empty " t * " in " * cite$ * warning$ }
    'output.nonnull
  if$
}

FUNCTION {output.bibitem}
{ newline$
  "\bibitem{" write$
  cite$ write$
  "}" write$
  newline$
  ""
  before.all 'output.state :=
}

% This function finishes all entries.
FUNCTION {fin.entry}
{ add.period$
  write$
  newline$
%  "\begin{verbatim}" write$
%  newline$
%  "@" write$
%  author write$
%  newline$
%  title write$
%  newline$
%  booktitle write$
%  newline$
%  { editor empty$
%      { "" }
%      { editor format.names
%        editor num.names$ #1 >
%          { ", editors" * }
%	  { ", editor" * }
%        if$
%      }
%    if$
%  }
%  editor write$
%  { editor empty$
%      { "" }
%      { "" }
%    if$
%  }
%  publisher write$
%  newline$
%  pages write$
%  newpage$
%  address write$
%  newpage$
%  month write$
%  newpage$
%  year write$
%  newpage$
% "\end{verbatim}" write$
%  newline$
}

FUNCTION {new.block}
{ output.state before.all =
    'skip$
    { after.block 'output.state := }
  if$
}

FUNCTION {new.sentence}
{ output.state after.block =
    'skip$
    { output.state before.all =
	'skip$
	{ after.sentence 'output.state := }
      if$
    }
  if$
}

% These three functions pop one or two (integer) arguments from the stack
% and push a single one, either 0 or 1.
% The 'skip$ in the `and' and `or' functions are used because
% the corresponding if$ would be idempotent
FUNCTION {not}
{   { #0 }
    { #1 }
  if$
}

FUNCTION {and}
{   'skip$
    { pop$ #0 }
  if$
}

FUNCTION {or}
{   { pop$ #1 }
    'skip$
  if$
}

% Sometimes we begin a new block only if the block will be big enough.  The
% new.block.checka function issues a new.block if its argument is nonempty;
% new.block.checkb does the same if either of its TWO arguments is nonempty.
FUNCTION {new.block.checka}
{ empty$
    'skip$
    'new.block
  if$
}

FUNCTION {new.block.checkb}
{ empty$
  swap$ empty$
  and
    'skip$
    'new.block
  if$
}

FUNCTION {new.sentence.checka}
{ empty$
    'skip$
    'new.sentence
  if$
}

FUNCTION {new.sentence.checkb}
{ empty$
  swap$ empty$
  and
    'skip$
    'new.sentence
  if$
}

% Here are some functions for formatting chunks of an entry.
% By convention they either produce a string that can be followed by
% a comma or period (using add.period$, so it is OK to end in a period),
% or they produce the null string.
%
% A useful utility is the field.or.null function, which checks if the
% argument is the result of pushing a `missing' field (one for which no
% assignment was made when the current entry was read in from the database)
% or the result of pushing a string having no non-white-space characters.
% It returns the null string if so, otherwise it returns the field string.
% Its main (but not only) purpose is to guarantee that what's left on the
% stack is a string rather than a missing field.
%
% field.or.null(s) ==
%  BEGIN
%	if empty$(s) then return ""
%	else return s
%  END
%
% Another helper function is emphasize, which returns the argument emphazised,
% if that is non-empty, otherwise it returns the null string.  Italic
% corrections aren't used, so this function should be used when punctation
% will follow the result.
%
% emphasize(s) ==
%  BEGIN
%	if empty$(s) then return ""
%	else return "{\em " * s * "}"
%
% The format.names function formats the argument (which should be in
% BibTeX name format) into "First Von Last, Junior", separated by commas
% and with an "and" before the last (but ending with "et~al." if the last
% of multiple authors is "others").  This function's argument should always
% contain at least one name.
%
% VAR: nameptr, namesleft, numnames: INTEGER
% pseudoVAR: nameresult: STRING		(it's what's accumulated on the stack)
%
% format.names(s) ==
%  BEGIN
%	nameptr := 1
%	numnames := num.names$(s)
%	namesleft := numnames
%	while namesleft > 0
%	  do
%				% for full names:
%	    t := format.name$(s, nameptr, "{ff~}{vv~}{ll}{, jj}")
%				% for abbreviated first names:
%	    t := format.name$(s, nameptr, "{f.~}{vv~}{ll}{, jj}")
%	    if nameptr > 1 then
%		if namesleft > 1 then nameresult := nameresult * ", " * t
%		else if numnames > 2
%		       then nameresult := nameresult * ","
%		     fi
%		     if t = "others"
%		       then nameresult := nameresult * " et~al."
%		       else nameresult := nameresult * " and " * t
%		     fi
%		fi
%	    else nameresult := t
%	    fi
%	    nameptr := nameptr + 1
%	    namesleft := namesleft - 1
%	  od
%	return nameresult
%  END
%
% The format.authors function returns the result of format.names(author)
% if the author is present, or else it returns the null string
%
% format.authors ==
%  BEGIN
%	if empty$(author) then return ""
%	else return format.names(author)
%	fi
%  END
%
% Format.editors is like format.authors, but it uses the editor field,
% and appends ", editor" or ", editors"
%
% format.editors ==
%  BEGIN
%	if empty$(editor) then return ""
%	else
%	    if num.names$(editor) > 1 then
%		return format.names(editor) * ", editors"
%	    else
%		return format.names(editor) * ", editor"
%	    fi
%	fi
%  END
%
% Other formatting functions are similar, so no "comment version" will be
% given for them.
%
% The `pop$' in this function gets rid of the duplicate `empty' value and
% the `skip$' returns the duplicate field value
FUNCTION {field.or.null}
{ duplicate$ empty$
    { pop$ "" }
    'skip$
  if$
}

FUNCTION {emphasize}
{ duplicate$ empty$
    { pop$ "" }
    { "{\em " swap$ * "}" * }
  if$
}

INTEGERS { nameptr namesleft numnames }

FUNCTION {format.names}
{ 's :=
  #1 'nameptr :=
  s num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    { s nameptr "{ff~}{vv~}{ll}{, jj}" format.name$ 't :=
      nameptr #1 >
	{ namesleft #1 >
	    { ", " * t * }
	    { numnames #2 >
		{ "," * }
		'skip$
	      if$
	      t "others" =
		{ " et~al." * }
		{ " and " * t * }
	      if$
	    }
	  if$
	}
	't
      if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
}

FUNCTION {format.authors}
{ author empty$
    { "" }
    { author format.names }
  if$
}

% The format.title function is used for non-book-like titles.
% For most styles we convert to lowercase (except for the very first letter,
% and except for the first one after a colon (followed by whitespace)),
% and hope the user has brace-surrounded words that need to stay capitilized;
% for some styles, however, we leave it as it is in the database.
FUNCTION {format.title}
{ title empty$
    { "" }
    { title }
  if$
}

% By default, BibTeX sets the global integer variable global.max$ to the BibTeX
% constant glob_str_size, the maximum length of a global string variable.
% Analogously, BibTeX sets the global integer variable entry.max$ to
% ent_str_size, the maximum length of an entry string variable.
% The style designer may change these if necessary (but this is unlikely)

% The n.dashify function makes each single `-' in a string a double `--'
% if it's not already
%
% pseudoVAR: pageresult: STRING		(it's what's accumulated on the stack)
%
% n.dashify(s) ==
%  BEGIN
%	t := s
%	pageresult := ""
%	while (not empty$(t))
%	  do
%	    if (first character of t = "-")
%	      then
%		if (next character isn't)
%		  then
%		    pageresult := pageresult * "--"
%		    t := t with the "-" removed
%		  else
%		    while (first character of t = "-")
%		      do
%			pageresult := pageresult * "-"
%			t := t with the "-" removed
%		      od
%		fi
%	      else
%		pageresult := pageresult * the first character
%		t := t with the first character removed
%	    fi
%	  od
%	return pageresult
%  END
FUNCTION {n.dashify}
{ 't :=
  ""
    { t empty$ not }
    { t #1 #1 substring$ "-" =
	{ t #1 #2 substring$ "--" = not
	    { "--" *
	      t #2 global.max$ substring$ 't :=
	    }
	    {   { t #1 #1 substring$ "-" = }
		{ "-" *
		  t #2 global.max$ substring$ 't :=
		}
	      while$
	    }
	  if$
	}
	{ t #1 #1 substring$ *
	  t #2 global.max$ substring$ 't :=
	}
      if$
    }
  while$
}

% The format.date function is for the month and year, but we give a warning if
% there's an empty year but the month is there, and we return the empty string
% if they're both empty.
FUNCTION {format.date}
{ year empty$
    { month empty$
	{ "" }
	{ "there's a month but no year in " cite$ * warning$
	  month
	}
      if$
    }
    { month empty$
	'year
	{ month " " * year * }
      if$
    }
  if$
}

% The format.btitle is for formatting the title field when it is a book-like
% entry---the style used here keeps it in uppers-and-lowers and emphasizes it.
FUNCTION {format.btitle}
{ title emphasize
}

% For several functions we'll need to connect two strings with a
% tie (~) if the second one isn't very long (fewer than 3 characters).
% The tie.or.space.connect function does that.  It concatenates the two
% strings on top of the stack, along with either a tie or space between
% them, and puts this concatenation back onto the stack:
%
% tie.or.space.connect(str1,str2) ==
%    BEGIN
%	if text.length$(str2) < 3
%	  then return the concatenation of str1, "~", and str2
%	  else return the concatenation of str1, " ", and str2
%    END
FUNCTION {tie.or.space.connect}
{ duplicate$ text.length$ #3 <
    { "~" }
    { " " }
  if$
  swap$ * *
}

% The either.or.check function complains if both fields or an either-or pair
% are nonempty.
%
% either.or.check(t,s) ==
%  BEGIN
%	if empty$(s) then
%	    warning$(can't use both " * t * " fields in " * cite$)
%	fi
%  END
FUNCTION {either.or.check}
{ empty$
    'pop$
    { "can't use both " swap$ * " fields in " * cite$ * warning$ }
  if$
}

% The format.bvolume function is for formatting the volume and perhaps
% series name of a multivolume work.  If both a volume and a series field
% are there, we assume the series field is the title of the whole multivolume
% work (the title field should be the title of the thing being referred to),
% and we add an "of <series>".  This function is called in mid-sentence.
FUNCTION {format.bvolume}
{ volume empty$
    { "" }
    { "volume" volume tie.or.space.connect
      "volume and number" number either.or.check
    }
  if$
}

% The format.number.series function is for formatting the series name
% and perhaps number of a work in a series.  This function is similar to
% format.bvolume, although for this one the series must exist (and the
% volume must not exist).  If the number field is empty we output either
% the series field unchanged if it exists or else the null string.
% If both the number and series fields are there we assume the series field
% gives the name of the whole series (the title field should be the title
% of the work being one referred to), and we add an "in <series>".
% We capitilize Number when this function is used at the beginning of a block.
FUNCTION {format.number.series}
{ volume empty$
    { number empty$
	{ output.state mid.sentence =
	    { "number" }
	    { "Number" }
	  if$
	  number tie.or.space.connect
	}
      if$
    }
    { "" }
  if$
}


% The format.pages function is used for formatting a page range in a book
% (and in rare circumstances, an article).
%
% The multi.page.check function examines the page field for a "-" or "," or "+"
% so that format.pages can use "page" instead of "pages" if none exists.
% Note: global.max$ here means "take the rest of the string"
%
% VAR: multiresult: INTEGER	(actually, a boolean)
%
% multi.page.check(s) ==
%  BEGIN
%	t := s
%	multiresult := false
%	while ((not multiresult) and (not empty$(t)))
%	  do
%	    if (first character of t = "-" or "," or "+")
%	      then multiresult := true
%	      else t := t with the first character removed
%	    fi
%	  od
%	return multiresult
%  END
INTEGERS { multiresult }

FUNCTION {multi.page.check}
{ 't :=
  #0 'multiresult :=
    { multiresult not
      t empty$ not
      and
    }
    { t #1 #1 substring$
      duplicate$ "-" =
      swap$ duplicate$ "," =
      swap$ "+" =
      or or
	{ #1 'multiresult := }
	{ t #2 global.max$ substring$ 't := }
      if$
    }
  while$
  multiresult
}

% This function doesn't begin a sentence so "pages" isn't capitalized.
% Other functions that use this should keep that in mind.
FUNCTION {format.pages}
{ pages empty$
    { "" }
    { pages multi.page.check
	{ "pages" pages n.dashify tie.or.space.connect }
	{ "page" pages tie.or.space.connect }
      if$
    }
  if$
}

% The format.vol.num.pages function is for the volume, number, and page range
% of a journal article.  We use the format:  vol(number):pages, with some
% variations for empty fields.  This doesn't begin a sentence.
FUNCTION {format.vol.num.pages}
{ volume field.or.null
  number empty$
    'skip$
    { "(" number * ")" * *
      volume empty$
	{ "there's a number but no volume in " cite$ * warning$ }
	'skip$
      if$
    }
  if$
  pages empty$
    'skip$
    { duplicate$ empty$
	{ pop$ format.pages }
	{ ":" * pages n.dashify * }
      if$
    }
  if$
}


% Now come the cross-referencing functions (these are invoked because
% one entry in the database file(s) cross-references another, by giving
% the other entry's database key in a `crossref' field).  This feature
% allows one or more titled things that are part of a larger titled
% thing to cross-reference the larger thing.  These styles allow for
% five posibilities: (1) an ARTICLE may cross-reference an ARTICLE;
% (2) a BOOK, (3) INBOOK, or (4) INCOLLECTION may cross-reference a BOOK;
% or (5) an INPROCEEDINGS may cross-reference a PROCEEDINGS.
% Each of these is explained in more detail later.
%
% An ARTICLE entry type may cross reference another ARTICLE (this is
% intended for when an entire journal is devoted to a single topic---
% but since there is no JOURNAL entry type, the journal, too, should be
% classified as an ARTICLE but without the author and title fields).
% This will result in two warning messages for the journal's entry
% if it's included in the reference list, but such is life.
%
% format.article.crossref ==
%  BEGIN
%	if empty$(key) then
%	    if empty$(journal) then
%		warning$("need key or journal for " * cite$ *
%						" to crossref " * crossref)
%		return(" \cite{" * crossref * "}")
%	    else
%		return("In " * emphazise.correct (journal) *
%						" \cite{" * crossref * "}")
%		fi
%	else
%	    return("In " * key * " \cite{" * crossref * "}")
%	fi
%  END
%
% The other cross-referencing functions are similar, so no "comment version"
% will be given for them.
FUNCTION {format.article.crossref}
{ key empty$
    { journal empty$
	{ "need key or journal for " cite$ * " to crossref " * crossref *
	  warning$
	  ""
	}
	{ "In {\em " journal * "\/}" * }
      if$
    }
    { "In " key * }
  if$
  " \cite{" * crossref * "}" *
}

% Now we define the type functions for all entry types that may appear
% in the .BIB file---e.g., functions like `article' and `book'.  These
% are the routines that actually generate the .BBL-file output for
% the entry.  These must all precede the READ command.  In addition, the
% style designer should have a function `default.type' for unknown types.
% Note: The fields (within each list) are listed in order of appearance,
% except as described for an `inbook' or a `proceedings'.
%
% The article function is for an article in a journal.  An article may
% CROSSREF another article.
%	Required fields: author, title, journal, year
%	Optional fields: volume, number, pages, month, note
%
% article ==
%  BEGIN
%	output.bibitem
%	output.check(format.authors,"author")
%	new.block
%	output.check(format.title,"title")
%	new.block
%	if missing$(crossref) then
%	    output.check(emphasize(journal),"journal")
%	    output(format.vol.num.pages)
%	    output.check(format.date,"year")
%       else
%	    output.nonnull(format.article.crossref)
%	    output(format.pages)
%	fi
%	new.block
%	output(note)
%	fin.entry
%  END
%
% The book function is for a whole book.  A book may CROSSREF another book.
%	Required fields: author or editor, title, publisher, year
%	Optional fields: volume or number, series, address, edition, month,
%			note
%
% book ==
%  BEGIN
%	if empty$(author) then output.check(format.editors,"author and editor")
%	else	output.check(format.authors,"author")
%		if missing$(crossref) then
%		    either.or.check("author and editor",editor)
%		fi
%	fi
%	new.block
%	output.check(format.btitle,"title")
%	if missing$(crossref) then
%	    output(format.bvolume)
%	    new.block
%	    output(format.number.series)
%	    new.sentence
%	    output.check(publisher,"publisher")
%	    output(address)
%       else
%	    new.block
%	    output.nonnull(format.book.crossref)
%	fi
%	output(format.edition)
%	output.check(format.date,"year")
%	new.block
%	output(note)
%	fin.entry
%  END
%
% The other entry functions are all quite similar, so no "comment version"
% will be given for them.

FUNCTION {article}
{ output.bibitem
%  format.authors "author" output.check
%  new.block
%  format.title "title" output.check
%  new.block
%  crossref missing$
%    { journal emphasize "journal" output.check
%      format.vol.num.pages output
%      format.date "year" output.check
%    }
%    { format.article.crossref output.nonnull
%      format.pages output
%    }
%  if$
%  new.block
%  note output
%  "\textbf{Autores:} " write$
  format.authors write$
  ". " write$
  "\href{" write$
  url write$
  "}{" write$
  format.title write$
  "}. " write$
  journal write$
  volume empty$
    {
    }
    {
       ", Vol. " write$
       volume write$
    }
  if$
  number empty$
    {
    }
    {
       ", n. " write$
       number write$
    }
  if$
  pages empty$
    {
    }
    {
       ", pp. " write$
       pages write$
    }
  if$
  %issn empty$
  %  {
  %  }
  %  {
  %     "; ISSN: " write$
  %     issn write$
  %  }
  %if$
  month empty$
    {
    }
    {
       ", " write$
       month write$
    }
  if$
  year empty$
    {
    }
    {
       ". " write$
       year write$
       ". " write$
    }
  if$
  %url empty$ {
  %  } {
  %  "URL: " write$
  %  "\href{" write$
  %  url  write$
  %  "}{" write$
  %  url write$
  %  "}" write$
  %  ". " write$
  %}
  %if$
%  if$
%  quality empty$
%    {
%    }
%    {
%       "\textbf{Indicios de calidad:} " write$
%       quality write$
%       ". " write$
%    }
%  if$
%  subject_categories empty$
%    {
%    }
%    {
%       "\textbf{Categor\'{\i}a (posici\'on/total):} " write$
%       subject_categories write$
%       ". " write$
%    }
  new.block
  %note output
  fin.entry
  "\href{http://www.hpca.ual.es/~vruiz/papers/" write$
  cite$ write$
  ".bib}{Bibtex entry.}" write$
%  doi empty$
%    {
%    }
%    {
%       " DOI: \href{" write$
%       doi write$
%       "}{" write$
%       doi write$
%       "}" write$
%    }
%  if$
}
% We use entry type `misc' for an unknown type; BibTeX gives a warning.
FUNCTION {default.type} { article }

% Here are macros for common things that may vary from style to style.
% Users are encouraged to use these macros.
%
% Months are either written out in full or abbreviated

MACRO {jan} {"January"}

MACRO {feb} {"February"}

MACRO {mar} {"March"}

MACRO {apr} {"April"}

MACRO {may} {"May"}

MACRO {jun} {"June"}

MACRO {jul} {"July"}

MACRO {aug} {"August"}

MACRO {sep} {"September"}

MACRO {oct} {"October"}

MACRO {nov} {"November"}

MACRO {dec} {"December"}

% Journals are either written out in full or abbreviated;
% the abbreviations are like those found in ACM publications.
%
% To get a completely different set of abbreviations, it may be best to make
% a separate .bib file with nothing but those abbreviations; users could then
% include that file name as the first argument to the \bibliography command

MACRO {acmcs} {"ACM Computing Surveys"}

MACRO {acta} {"Acta Informatica"}

MACRO {cacm} {"Communications of the ACM"}

MACRO {ibmjrd} {"IBM Journal of Research and Development"}

MACRO {ibmsj} {"IBM Systems Journal"}

MACRO {ieeese} {"IEEE Transactions on Software Engineering"}

MACRO {ieeetc} {"IEEE Transactions on Computers"}

MACRO {ieeetcad}
 {"IEEE Transactions on Computer-Aided Design of Integrated Circuits"}

MACRO {ipl} {"Information Processing Letters"}

MACRO {jacm} {"Journal of the ACM"}

MACRO {jcss} {"Journal of Computer and System Sciences"}

MACRO {scp} {"Science of Computer Programming"}

MACRO {sicomp} {"SIAM Journal on Computing"}

MACRO {tocs} {"ACM Transactions on Computer Systems"}

MACRO {tods} {"ACM Transactions on Database Systems"}

MACRO {tog} {"ACM Transactions on Graphics"}

MACRO {toms} {"ACM Transactions on Mathematical Software"}

MACRO {toois} {"ACM Transactions on Office Information Systems"}

MACRO {toplas} {"ACM Transactions on Programming Languages and Systems"}

MACRO {tcs} {"Theoretical Computer Science"}

% Now we read in the .BIB entries.
READ

% Now comes the computation for numeric labels.
% We use either the sorted order or original order.
% We still have to keep track of the longest (in width$ terms) label, for use
% by the "thebibliography" environment.

STRINGS { longest.label }

INTEGERS { number.label longest.label.width }

FUNCTION {initialize.longest.label}
{ "" 'longest.label :=
  #1 'number.label :=
  #0 'longest.label.width :=
}

FUNCTION {longest.label.pass}
{ number.label int.to.str$ 'label :=
  number.label #1 + 'number.label :=
  label width$ longest.label.width >
    { label 'longest.label :=
      label width$ 'longest.label.width :=
    }
    'skip$
  if$
}

EXECUTE {initialize.longest.label}

ITERATE {longest.label.pass}

% Escribe la cadena `\begin{thebibliography}{<numero_de_entradas>}'
% Now we're ready to start writing the .BBL file.
% We begin, if necessary, with a LaTeX macro for unnamed names in an alphabetic
% label; next comes stuff from the `preamble' command in the database files.
% Then we give an incantation containing the command
%     \begin{thebibliography}{...}
% where the `...' is the longest label.
%
% We also call init.state.consts, for use by the output routines.
FUNCTION {begin.bib}
{ preamble$ empty$
    'skip$
    { preamble$ write$ newline$ }
  if$
  "\begin{thebibliography}{"  longest.label  * "}" * write$ newline$
}

EXECUTE {begin.bib}

EXECUTE {init.state.consts}

% Now we produce the output for all the entries
ITERATE {call.type$}

% Finally, we finish up by writing the `\end{thebibliography}' command.
FUNCTION {end.bib}
{ newline$
  "\end{thebibliography}" write$ newline$
}

EXECUTE {end.bib}
