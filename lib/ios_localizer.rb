require "ios_localizer/version"

require 'uri'
require 'net/https'
require 'json'
require 'cgi'
require 'htmlentities'

module IosLocalizer

	class HelperMethods
		# setup regular expressions

		$regex = /^".*" = "(.*)";$/

		# Helper functions

		def getDataFromURL(url)
			uri = URI.parse(url.strip)
			http = Net::HTTP.new(uri.host,uri.port)
			http.use_ssl = true
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			lr = http.request(Net::HTTP::Get.new(uri.request_uri))
			JSON.parse (lr.body)
		end 

		def directory_exists?(directory)
			File.directory?(directory)
		end

		def extract_word(line)
			$regex.match(line)[1]
		end

		def should_line_be_translated (line)
			$regex.match(line) != nil
		end

	end

	def IosLocalizer.localize(key, proj_dir, source, skip)

		h = HelperMethods.new

		source_strings_file = proj_dir + "/" + source + ".lproj/Localizable.strings"

		#Get languages

		lurl = 'https://www.googleapis.com/language/translate/v2/languages?key=' + key

		ldata = h.getDataFromURL (lurl)

		if ldata.has_key? 'Error'
			raise "web service error"
		end

		languages = Array.new

		ldata["data"]["languages"].each do |language|
			unless language["language"].eql? source 
				unless skip.include? language["language"] 
					lproj_dir = proj_dir + "/" +language["language"] +".lproj"
					if h.directory_exists?(lproj_dir)
						languages << language["language"]
					end
				end
			end
		end		

		#Generate source language file

		gen_strings_command = "find " + proj_dir + "/ -name *.m -print0 | xargs -0 genstrings -o " + proj_dir + "/" + source + ".lproj"
		system(gen_strings_command)

		#Get words that need to be translated

		words = Array.new
		comment_str = "/*"
		src = File.open(source_strings_file, "rb:UTF-16LE")
		while (line = src.gets)
			line = line.encode('UTF-8')
			if h.should_line_be_translated(line)
				words << h.extract_word(line)
			end
		end

		#Prepare Translate Query

		turl =  "https://www.googleapis.com/language/translate/v2?key=" + key + "&source=" + source
		words.each do |word|
			turl += "&q=" + CGI::escape(word)
		end

		#Translate Words & write new file

		coder = HTMLEntities.new

		languages.each do |lang|
			lang_strings_file = proj_dir + "/" + lang + ".lproj/Localizable.strings"
			dest = File.open(lang_strings_file, "w")

			translate_url = turl + "&target=" + lang
			tdata = h.getDataFromURL(translate_url)	

			i = 0
			src = File.open(source_strings_file, "rb:UTF-16LE")
			while (line = src.gets)
				line = line.encode('UTF-8')
				if h.should_line_be_translated(line)
					extracted_word = (h.extract_word(line))
					line = line.reverse.sub(extracted_word.reverse, coder.decode(tdata["data"]["translations"][i]["translatedText"]).reverse).reverse
					dest.syswrite(line)
					i += 1
				else
					dest.syswrite(line)
				end
			end
		end
	end

end
