#!/usr/bin/ruby
# == Synopsis
#
# rjstags: parses javascript source fiels and generates tag file.
#
# == Usage
#
# rjstags [OPTIONS] ... PATH
#
# --help, -h:
#    show help.
#
# --extensions js,phtml,html, -e js:
#    extensions to parse. must be separated with comma. default is js.
#
# --libraries, -l:
#    which js libraries you are going to parse(JQuery, ExtJS, Prototype are supported). must be separated with comma.
#
# --exclude, -x:
#    Exclude files and directories matching patern.
#
# PATH: The path in which to parse files.

require 'getoptlong'
require 'rdoc/usage'
require 'pp'

dir = Dir.getwd
Dir.chdir(__FILE__.sub(/[\w.]+$/, ''))
require 'rbnarcissus/parser'
require 'syntax_tree'
Dir.foreach('parsers') do |filename|
  next if [".", ".."].include?(filename)
  require 'parsers/'+filename
end
Dir.chdir(dir)

$TEST ||= false

module RjsTags
  @@files = nil
  @@options = nil

  #
  # test function
  #
  def self.test(text, options={:libraries => 'Common'})
    parsers = options[:libraries].map {|v| eval(v+"Parser") }
    text = self.filter_code(text)
    syntax_tree = SyntaxTree.new(Narcissus.parse(text, 'test.js'), parsers);
    syntax_tree.get_test
  end


  #
  # main function
  #
  def self.make_tags(path, options)
    @@files = []

    @@options = options
    @@options[:extensions] = Regexp.new(@@options[:extensions].map {|v| "\\."+v+'$' }.join('|'))
    if FileTest.directory?(path)
      self.scan_dir(path)
    else
      @@files << path
    end

    parsers = @@options[:libraries].map {|v| eval(v+"Parser") }

    tags = []
    File.open('tags', 'r') {|f| tags = f.readlines } if File.exists?('tags')
    tags = tags.select {|v| v !~ /^\!/ }
    @@files.each do |file|
      $filename = file
      $lines = nil
      code = nil

      File.open(file) {|f| code = f.read }

      print 'parsing '+file+' ... '
      STDOUT.flush
      code_original = String.new(code)
      code = self.filter_code(code)
      $lines = code.split("\n")

      if @@options[:debug]
        $debug = @@options[:debug]
        File.open('tags', 'w') {|f| f << code }
        syntax_tree = SyntaxTree.new(Narcissus.parse(code, file), parsers)
        tags = tags.select {|v| v !~ Regexp.new("\t"+file+"\t") } + syntax_tree.get_tags
        puts ""
        puts syntax_tree.get_test
        puts ""
        exit
      else
        begin
          syntax_tree = SyntaxTree.new(Narcissus.parse(code, file), parsers)
          tags = tags.select {|v| v !~ Regexp.new("\t"+file+"\t") } + syntax_tree.get_tags
          puts "success"
        rescue
          puts "fail "
          # if we got exception let's try again w/o code filter
          code = code_original
          $lines = code.split("\n")
          print 'parsing '+file+' w/o code filter ... '
          begin
            syntax_tree = SyntaxTree.new(Narcissus.parse(code, file), parsers)
            tags = tags.select {|v| v !~ Regexp.new("\t"+file+"\t") } + syntax_tree.get_tags
            puts "success"
          rescue
            puts "fail"
          end
        end
      end
    end

    tags = ['!_TAG_FILE_FORMAT	2	/extended format; --format=1 will not append ;" to lines/
!_TAG_FILE_SORTED	1	/0=unsorted, 1=sorted, 2=foldcase/
!_TAG_PROGRAM_AUTHOR	Darren Hiebert	/dhiebert@users.sourceforge.net/
!_TAG_PROGRAM_NAME	Exuberant Ctags	//
!_TAG_PROGRAM_URL	http://ctags.sourceforge.net	/official site/
!_TAG_PROGRAM_VERSION	5.8	//
'] + tags.sort
    File.open('tags', 'w') {|f| f << tags.join }
  end


  #
  # filters source code with regula expressions
  #
  def self.filter_code(text)
    # remove comments
    text.gsub!(/(?:^|\s+)
                \/\*
                  [^*]+
                \*\/
               /x, '')
    text.gsub!(/(^|\s+|\{|\})
                  \/\/.*$
               /x, '\1')
    # remove 'return'
    text.gsub!(/(?:^|\s+)return\s*(?!\w|\{)
                                        (:?[^{};\n]+;(?=\s*\n)|\{[^;]*\};)
               /x, ';')
    # remove 'while|for|switch|if|else|catch|try'
    2.times do
      text.gsub!(/(?:^|\s+)(while|for|switch|if|catch|try|with)\s*
                                              \(
                                                (?>
                                                  [^()]+
                                                  |
                                                  \(
                                                    (?>
                                                      [^()]+
                                                      |
                                                      \(
                                                        (?>
                                                          [^()]+
                                                          |
                                                          \(
                                                            [^()]*
                                                          \)
                                                        )*
                                                      \)
                                                    )*
                                                  \)
                                                )*
                                              \)
                                              \s*
                                              \{
                                                (?>
                                                  [^{}]+
                                                  |
                                                  \{
                                                    (?>
                                                      [^{}]+
                                                      |
                                                      \{
                                                        (?>
                                                          [^{}]+
                                                          |
                                                          \{
                                                            [^{}]*
                                                          \}
                                                        )*
                                                      \}
                                                    )*
                                                  \}
                                                )*
                                              \}
                /x, ';')
      text.gsub!(/(?:^|\s+)else\s*
                                              \{
                                                (?>
                                                  [^{}]+
                                                  |
                                                  \{
                                                    (?>
                                                      [^{}]+
                                                      |
                                                      \{
                                                        (?>
                                                          [^{}]+
                                                          |
                                                          \{
                                                            [^{}]*
                                                          \}
                                                        )*
                                                      \}
                                                    )*
                                                  \}
                                                )*
                                              \}
                /x, ';')
    end
    # remove conditional
    text.gsub!(/\?[^?:\n]+=[^?:\n]+\:/, '? 1 :')
    # remove '; else if'
    text.gsub!(/(?:\s*else;)+/, ';')
    text.gsub!(/\s*else\s*/, ';')
    text.gsub!(/\s*catch\s*/, 'try{}catch')

    text
  end


  #
  # scans filesystem and returns list of files
  #
  def self.scan_dir(path)
    Dir.entries(path).each do |entry|
      next if entry == '.' || entry == '..'
      self.scan_dir(path+'/'+entry) if FileTest.directory?(path+'/'+entry)
      next if entry !~ @@options[:extensions]
      next if entry =~ @@options[:exclude]

      @@files << path+'/'+entry
    end
  end
end


unless $TEST
  opts = GetoptLong.new(
    [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
    [ '--libraries', '-l', GetoptLong::REQUIRED_ARGUMENT ],
    [ '--extensions', '-e', GetoptLong::REQUIRED_ARGUMENT ],
    [ '--exclude', '-x', GetoptLong::REQUIRED_ARGUMENT ],
    [ '--debug', '-d', GetoptLong::NO_ARGUMENT ]
  )

  dir = nil
  options = {:extensions => ["js"], :libraries => ["Common"], :exclude => /(?=QWERTYU)/, :debug => false}

  opts.each do |opt, arg|
    case opt
      when '--help'
        RDoc::usage

      when '--extensions'
        options[:extensions] = arg.to_s.split(',')

      when '--libraries'
        options[:libraries] += arg.to_s.split(',')

      when '--exclude'
        options[:exclude] = Regexp.new(arg)

      when '--debug'
        options[:debug] = true
        $debug = true
    end
  end

  if ARGV.length != 1
    puts "Missing path argument (try --help)"
    exit 0
  end

  RjsTags.make_tags(ARGV.shift, options)
end
