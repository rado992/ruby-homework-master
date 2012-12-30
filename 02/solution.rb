class Song
  attr_reader :name, :artist, :album

  def initialize(name, artist, album)
    @name = name
    @artist = artist
    @album = album
  end
end

module FilterHelper
  def meets_criterium(crit, song)
    c1 = (crit[:names].empty? or crit[:names].include? song.name)
    c2 = (crit[:arts].empty? or crit[:arts].include? song.artist)
    c3 = (crit[:albs].empty? or crit[:albs].include? song.album)
    c1 and c2 and c3
  end
end

class Collection
  #attr_accessor :song_array, :name_list, :artist_list, :album_list
  include Enumerable

  include FilterHelper

  attr_reader :song_array

  def self.parse(text)
    song_array = text.split("\n").each_slice(4).map do |name, artist, album|
      Song.new name.chomp, artist.chomp, album.chomp
    end

    new song_array
  end

  def initialize(text)
    @song_array = song_array
  end

  def each(&block)
    @song_array.each(&block)
  end

  def names
    @song_array.map(&:name).uniq
  end

  def artists
    @song_array.map(&:artist).uniq
  end

  def albums
    @song_array.map(&:album).uniq
  end

  def filter(criteria)
    Collection.new @song_array.select { |song| criteria.matches? song }
  end

  def adjoin(other_coll)
    Collection.new self.songs | other_coll.songs
  end
end

module Criteria
  def name(song_name)
    Criterion.new { |song| song.name == song_name }

  def artist(song_artist)
    Criterion.new { |song| song.artist == song_artist }
  end

  def album(song_album)
    Criterion.new { |song| song.artist == song_album }
  end
end

class Criterion
  def initialize(&block)
    @predicate = block
  end

  def matches?(song)
    @predicate.(song)
  end

  def !
    Criterion.new { |song| not matches?(song) }
  end

  def &(other)
    Criterion.new { |song| self.matches?(song) and other.matches?(song) }
  end

  def |(other)
    Criterion.new { |song| self.matches?(song) or other.matches?(song) }
  end
end