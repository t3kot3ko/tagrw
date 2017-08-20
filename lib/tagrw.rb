require "tagrw/version"
require "mp3info"

module Tagrw
  # TODO: separate writing buffer from Data
  # pictures = array of paths to pictures
  class Data < Struct.new(:filepath, :track, :artist, :album, :title, :pictures)
    EMPTY = "(empty)"

    def initialize(*args)
      super(*args)
      self.pictures ||= []
    end

    def to_s
      empty = "(empty)"
      return pretty_format(
        self.filepath || EMPTY, 
        self.track || EMPTY,
        self.artist || EMPTY, 
        self.album || EMPTY, 
        self.title || EMPTY, 
      )
    end

    def diff(other)
      data = [:filepath, :track, :artist, :album, :title].map do |key|
        if self.send(key) == other.send(key)
          "#{self.send(key) || EMPTY} (same)"
        else
          "#{self.send(key) || EMPTY} => #{other.send(key) || EMPTY}"
        end
      end
      pretty_format(*data)
    end

    private 
    def pretty_format(filepath, track, artist, album, title)
      return <<~EOF
      * #{File.basename(filepath)}
        |-- track:  #{track || empty}
        |-- artist: #{artist|| empty}
        |-- album:  #{album || empty}
        |-- title:  #{title || empty}
      EOF

    end
  end

  # Write v1/v2 tags for artist/album/title/track#
  def self.write_tag(data)
    Mp3Info.open(data.filepath) do |mp3|
      mp3.tag.artist = data.artist
      mp3.tag2.TPE1 =  data.artist

      mp3.tag.album = data.album
      mp3.tag2.TALB = data.album

      mp3.tag2.TRCK = data.track
      mp3.tag.title = data.title

      # picture
      unless data.pictures.empty?
        mp3.tag2.remove_pictures    # remove all images
        data.pictures.each do |path|
          next unless File.exists?(path)
          next unless %w(.jpg .png).include?(File.extname(path).downcase)

          mp3.tag2.add_picture(File.open(path, "rb").read)
        end
      end
    end
  end

  def self.inspect(filepath)
    Mp3Info.open(filepath) do |mp3|
      # TODO: the case when v1/v2 tags are different
      
      # artist
      tag_artist = mp3.tag.artist
      tag2_tpe1 = mp3.tag2.TPE1

      # album
      tag_album = mp3.tag.album
      tag2_talb = mp3.tag2.TALB

      # track
      track = mp3.tag2.TRCK

      title = mp3.tag.title

      return Data.new(filepath, track, tag_artist, tag_album, title)
    end
  end

  def self.print(filepath, track, artist, album, title)
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
