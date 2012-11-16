HistoryFile
===========

Behaves like a {File} class and does some convenience stuff
around a {HistoryFile::FileDelegator} instance. It all
revolves about defining a time offset. If however, you want
to access different versions of a file, use it like this:

```ruby
> f = HistoryFile[1.day.ago].new("/tmp/foo.txt", "w")
=> #<File:/tmp/2012.11.02-foo.txt>
```

The returned {HistoryFile::FileDelegator} object supports all
methods that File has, but adds a date prefix to those methods
that revolve around a single file (reading, writing, etc.)

If a file for a given date is not available, {HistoryFile} falls
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