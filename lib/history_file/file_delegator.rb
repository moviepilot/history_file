module HistoryFile
  # This class delegates all method calls to the `File` class.
  # The generic methods that don't revolve around one specific
  # file, `File.join` for example, are just passed on. These
  # methods are defined in
  # {HistoryFile::FileDelegator::EXCLUDED_METHODS}.
  #
  # The methods that revolve around doing something with one
  # specific file, however, will be called with an altered
  # Filename. Consider this example:
  #
  #     > fd = HistoryFile::FileDelegator.new("some_prefix")
  #     > fd.open("/path/to/my_file.txt", "w") do |io|
  #     >  io.puts "hello there"
  #     > end
  #     > puts fd.read("/path/to/my_file.txt")
  #     => hello there
  #
  # This will pass on your block to `File.open`, but with a
  # prefixed the filename. So what's really called is:
  #
  #     File.open("/path/to/some_prefix-my_file.txt")
  #
  # For methods that get a bunch of filenames, but only filenames,
  # as arguments, all of the filenames are patched to include the
  # date prefix. These methods are defined in
  # {HistoryFile::FileDelegator::BULK_METHODS}
  #
  # You shouldn't need to instanciate this class directly,
  # {HistoryFile} wraps this for you.
  class FileDelegator
    EXCLUDED_METHODS = [
      :absolute_path,
      :basename,
      :catname,
      :chmod,
      :chown,
      :compare,
      :copy,
      :directory?,
      :dirname,
      :expand_path,
      :extname,
      :fnmatch,
      :fnmatch?,
      :identical?,
      :install,
      :join,
      :lchown,
      :link,
      :makedirs,
      :move,
      :path,
      :realdirpath,
      :realpath,
      :rename,
      :split,
      :umask,
      :utime
    ]

    BULK_METHODS = [
      :delete,
      :unlink,
      :safe_unlink
    ]

    # @param prefix [String] The prefix for all methods that revolve around
    #   filenames
    # @param fallback_glob [Hash] If you want to fall back to an alphabetically
    #   smaller file on Errno::ENOENT, you can supply a :fallback_glob here. It
    #   will be used with `Dir.glob` to find all candidates (so this should match
    #   all prefixes)
    def initialize(prefix, opts = {})
      @prefix = prefix
      @fallback_glob = opts[:fallback_glob]
      @subdir = opts[:use_subdirectories]
    end

    # Either
    # - passes on the call directly to File (why am I not 
    #   removing this feature?) or
    # - adds the date prefix to the first argument or
    # - adds the date prefix to all arguments
    def delegate(*args, &block)
      method = args.slice!(0,1).first
      if EXCLUDED_METHODS.include?(method)
        File.send(method, *args, &block)
      elsif BULK_METHODS.include?(method)
        delegate_with_patched_filenames(method, *args, &block)
      else
        delegate_with_patched_filename(method, *args, &block)
      end
    end

    def prefixed_filename(f)
      dir  = File.dirname(f.to_s)
      file = File.basename(f.to_s)
      if @subdir
        File.join(dir, @prefix, file)
      else
        File.join(dir, "#{@prefix}-#{file}")
      end
    end

    private

    def file_fallback(original_filename, target_filename)
      return false unless @fallback_glob
      dir   = File.dirname(original_filename.to_s)
      file  = File.basename(original_filename.to_s)
      glob  = File.join(dir, @fallback_glob+file)
      candidates = Dir[glob].sort.select do |c|
        c < target_filename
      end.last
    end

    # Treats the first argument of the method as a file and passes
    # the rest on as is. If we get a file not found exception, we'll
    # fall back to the next older version we find.
    def delegate_with_patched_filename(method, *args, &block)
      filename = args.slice!(0,1).first
      pf = prefixed_filename(filename)
      begin
        File.send(method, pf, *args, &block)
      rescue Errno::ENOENT => e
        raise e unless fallback = file_fallback(filename, pf)
        File.send(method, fallback, *args, &block)
      end
    end

    # Treats all arguments of the methods as files and prepends the 
    # history prefix
    def delegate_with_patched_filenames(method, *args, &block)
      pfs = args.map{ |f| prefixed_filename(f) }
      File.send(method, *pfs, &block)
    end

    # TL;DR: This is essentially a method missing, but only for the class
    #        methods of {File} and without the side effects.
    #
    # Since method missing causes weird things (especially in tests and
    # puts), we just define all methods. Keeps me from overwriting/aliasing
    # all the methods as I would have to do when inheriting from File.
    ((File.methods-Object.methods)+[:new]).sort.each do |m|
      self.send(:define_method, m) do |*args, &block|
        delegate(*([m]+args), &block)
      end
    end
  end
end
