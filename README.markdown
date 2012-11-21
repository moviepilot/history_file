HistoryFile
===========

Behaves like a `File` class and does some convenience stuff
around a `HistoryFile::FileDelegator` instance. It lets you 
version files by dates. A date prefix is added to the file
name.

If you want to write a file to store data from yesterday, 
you could write:

```ruby
> f = HistoryFile[1.day.ago].new("/tmp/foo.txt", "w")
=> #<File:/tmp/2012.11.02-foo.txt>
```

The returned `HistoryFile::FileDelegator` object supports all
methods that File has, but adds a date prefix to those methods
that revolve around a single file (reading, writing, etc.)

If a file for a given date is not available, `HistoryFile` falls
back to the freshest file that is older than the given date.

```ruby
> f = HistoryFile[3.days.ago].new("test.txt", "w")
=> #<File:./2012.11.12-test.txt>
> f.write("I am old")
=> 8
> f.close
=> nil
> HistoryFile[Date.today].read("test.txt")
=> "I am old"
> HistoryFile[10.days.ago].read("test.txt")
Errno::ENOENT: No such file or directory - ./2012.11.05-test.txt
```
It does this for every method where a prefix is added and when
an `Errno::ENOENT` is thrown.

Methods that patch all arguments with a date prefix
---------------------------------------------------
You can pass an arbitrary amount of arguments to these methods,
but all of them are file names. So we'll go ahead and prefix all
of them:

- `delete`
- `unlink`
- `safe_unlink`

Methods that patch nothing and just delegate to File
----------------------------------------------------
These are mostly methods that are either not `HistoryFile` specific
(i.e. `File.join` to join components with the OS dependant path 
separator) or where one can't dumbly prefix filenames. 

- `absolute_path`
- `basename`
- `catname`
- `chmod`
- `chown`
- `compare`
- `copy`
- `directory?`
- `dirname`
- `expand_path`
- `extname`
- `fnmatch`
- `fnmatch?`
- `identical?`
- `install`
- `join`
- `lchown`
- `link`
- `makedirs`
- `move`
- `path`
- `realdirpath`
- `realpath`
- `rename`
- `split`
- `umask`
- `utime`

Methods that add a prefix to the filename
-----------------------------------------
All methods not mentioned in the previous two sections

Methods that automatically create a sub directory
-------------------------------------------------
If you set `HistoryFile.mode = :subdir` and you call one of the
following methods, Historyfile will create a sub directory for the given
date if it does not exist already

- `new`
- `open`

Tests
-----
We use simplecov and it reports 100% coverage.
[![Build Status](https://secure.travis-ci.org/moviepilot/history_file.png?branch=master)](https://travis-ci.org/moviepilot/history_file)
