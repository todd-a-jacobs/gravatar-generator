#!/usr/bin/env ruby

# == Name
#    gravgen.rb
#
# == Version
#    $Id$
#
# == Purpose
#    Use the gravtar.com public API to retrieve or generate avatars.
#
# == Features
#    * Works as both a library and as a standalone executable.
#    * Works out of the box. No programming required!
#    * Does NOT require rubygems, unless you want to run the included
#      rake tasks or rspec tests. Neither is necessary for routine
#      operation.
#    * Self-documenting through the magic of RDoc::usage.
#
# == Usage
#    gravgen.rb [OPTIONS] [FILENAME]
#
#    --help, -h:
#        Show complete documentation.
#    --license, -l:
#        Display license.
#    --usage, -u:
#        Show program options.
#    --version, -v:
#        Display this program's version information.
#
#    --email <email_address>, -e <email_address>:
#        Email address to hash for the avatar.
#    --filename <string>, -f <string>:
#        Output filename for avatar.
#    --format <valid_format_code>, -t <valid_format_code>:
#        Valid code for an avatar format. Defaults to 'identicon.'
#    --size <integer>, -s <integer>
#        Valid image size. Defaults to '80.'
#
# == Examples
#    # Create a random 80x80 avatar, display its introspected values,
#    # and store it to disk.
#    #
#    # HINT: reuse the value of @email if you want to recreate a
#    # particular random avatar at a different size later on!
#    gravgen.rb
#
#    # Save identicon for email address foo@example.com to a foo.png
#    # file.
#    gravgen.rb -e foo@example.com foo.png
#
#    # Create wavatar for bar@example.com on stdout.
#    gravgen.rb -e bar@example.com -f- > /tmp/wavatar.png
#
#    # Create random 512x512 monsterid.
#    gravgen.rb -s 512 -t monsterid /tmp/monsterid.png
#
#    # Run a Bash 4.x one-liner to generate 10 random identicons so you
#    # can pick the one you like best.
#    for x in {1..10}; do gravgen.rb; done
#
#    # Use email address encoded into the filename of a random image as
#    # the basis for a resized copy.
#    gravgen.rb --size 32 --email $(
#      ls avatar_31765_d0d632d0-aecb-4f75-badf-0a9b8d63c891.png |
#      cut -d- -f2- |
#      cut -d. -f1
#    )
#
# == Errorlevels
#    0 = Success
#    1 = Failure
#    99 = Help/Usage
#
# == Copyright:
#    Copyright 2010 Todd A. Jacobs
#    All Rights Reserved
#
# == License
#    Released under the GNU General Public License (GPL)
#    http://www.gnu.org/copyleft/gpl.html
#
#    This program is free software; you can redistribute it and/or
#    modify it under the terms of the GNU General Public License as
#    published by the Free Software Foundation; either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful, but
#    WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#    General Public License for more details.

require 'uri'
require 'net/http'
require 'ostruct'
require 'getoptlong'
require 'rdoc/usage'
require 'digest/md5'

# Provides an encapsulated object for retrieving or generating an avatar
# using the gravatar API.
class Avatar
  attr_reader :email, :email_hash, :type, :size, :image
  API_URL = 'http://www.gravatar.com/avatar'
  TYPES = %w[identicon monsterid wavatar retro]
  EXTENSIONS = %w[png jpg]
  MIN_SIZE_IN_PX = 1
  MAX_SIZE_IN_PX = 512

  # Instantiate a new avatar object with zero or more options:
  #  * :email => String
  #  * :type  => String
  #  * :size  => Integer
  def initialize options={}
    @email = options[:email] || nil
    @type  = options[:type]  || TYPES.first
    @size  = options[:size]  || 80
    sanity_check
    @email = `uuidgen`.chomp.strip if @email.nil?
    @email_hash = Digest::MD5.hexdigest @email.chomp.strip.downcase
  end

  # Perform basic sanity check of the instantiated object. Raises
  # exceptions if the object's values don't conform to requirements.
  def sanity_check
    if @email.nil?
      raise 'uuidgen missing from path' unless uuidgen_in_path?
    end
    if @size < MIN_SIZE_IN_PX or @size > MAX_SIZE_IN_PX
      raise ArgumentError "invalid size: #{@size}"
    end
    raise ArgumentError "invalid type: #{@type}" unless valid_type?
  end

  # Retrieve avatar via API, and store it in the @image attribute.
  def fetch
    uri_template = '%s/%s?d=%s&s=%d'
    @url = uri_template % [API_URL, @email_hash, @type, @size]
    @image = Net::HTTP.get URI.parse(@url)
  end

  # Write avatar data to named file.
  def write filename
    file_handle = File.open(filename, 'w+')
    file_handle.print @image
    file_handle.close
  end

  private

  # Check path for uuidgen binary. Returns true if found.
  def uuidgen_in_path?
    `which uuidgen`
    $?.exitstatus == 0 ? true : false
  end

  # Boolean: If attribute @type is listed in Avatar::TYPES, returns
  # true.
  def valid_type?
    TYPES.include? @type
  end
end # class Avatar

if __FILE__ == $0
    options = OpenStruct.new
    opts = GetoptLong.new(
	[ '--help',     '-h', GetoptLong::NO_ARGUMENT ],
	[ '--license',  '-l', GetoptLong::NO_ARGUMENT ],
	[ '--usage',    '-u', GetoptLong::NO_ARGUMENT ],
	[ '--version',  '-v', GetoptLong::NO_ARGUMENT ],
	[ '--examples', '-x', GetoptLong::NO_ARGUMENT ],
	[ '--email',    '-e', GetoptLong::REQUIRED_ARGUMENT ],
	[ '--filename', '-f', GetoptLong::REQUIRED_ARGUMENT ],
	[ '--format',   '-t', GetoptLong::REQUIRED_ARGUMENT ],
	[ '--size',     '-s', GetoptLong::REQUIRED_ARGUMENT ]
    )
    opts.each do |opt, arg|
	case opt
	    when '--help'
	      RDoc::usage
	    when '--license'
	      RDoc::usage 'License'
	    when '--usage'
	      RDoc::usage 'Usage'
	    when '--version'
	      RDoc::usage 'Version'
	    when '--examples'
	      RDoc::usage 'Examples'
	    when '--email'
		options.email = arg.downcase
	    when '--format'
		options.format = arg.downcase
	    when '--size'
		options.size = arg.to_i
	    when '--filename'
                raise "file exists: #{arg}" if File.exists? arg
		options.filename = arg
	end # case
    end # opts.each

    avatar = Avatar.new(
      :email => options.email,
      :type => options.format,
      :size => options.size
    )

    # If the script is passed a filename...
    if options.filename or ARGV[0]
      avatar.fetch
      # Handle stdout as a special case filename.
      if options.filename == '-'
        print avatar.image
      else
        avatar.write options.filename || ARGV[0]
      end
    else
      # Inspect before fetch, to ensure that stdout isn't flooded with
      # binary data.
      puts avatar.inspect
      avatar.fetch
      # Use the PID and UUID to create a unique filename. The email
      # address is encoded into the latter portion of the filename.
      output_file = "avatar_#{$$}_#{avatar.email}.png"
      unless File.exists? output_file
        avatar.write output_file
        puts 'Created ' << output_file
      end
    end
end # if __FILE__ == $0
