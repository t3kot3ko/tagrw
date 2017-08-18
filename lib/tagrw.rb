require "tagrw/version"
require "mp3info"

module Tagrw
	# Write v1/v2 tags for artist/album/title/track#
	def self.write_tag(filepath, artist, album, title, track)
		Mp3Info.open(filepath) do |mp3|
			mp3.tag.artist = artist
			mp3.tag2.TPE1 = artist

			mp3.tag.album = album
			mp3.tag2.TALB = album

			mp3.tag2.TRCK = track
		end
	end

	def self.show(filepath)
		Mp3Info.open(filepath) do |mp3|
			# artist
			tag_artist = mp3.tag.artist
			tag2_tpe1 = mp3.tag2.TPE1

			# album
			tag_album = mp3.tag.album
			tag2_talb = mp3.tag2.TALB

			# track
			track = mp3.tag2.TRCK

			puts [track, mp3.tag.title, tag_artist, tag_album].join("\t")
		end
	end

	# TODO: use regexp
	def self.valid_filename?(filename, delimiter)
		ext = File.extname(filename)
		return false if ext.downcase != ".mp3"

		basename = File.basename(filename, ext)
		index, *title = basename.split(delimiter)

		return false if title.empty?

		return true
	end
end
