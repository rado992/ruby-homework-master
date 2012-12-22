class Song
  attr_accessor :name, :artist, :album

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
  attr_accessor :song_array, :name_list, :artist_list, :album_list

  include Enumerable

  include FilterHelper

  def initialize(text)
    self.song_array, self.name_list = [], []
    self.artist_list, self.album_list = [], []
    text.split("\n").each_slice(4) do |name, artist, album|
      self.song_array << Song.new(name, artist, album)
    end
  end

  def self.parse(text)
    Collection.new(text)
  end

  def each
    song_array.each do |song|
      yield song
    end
  end

  def filter(criterium)
    coll = Collection.new("")
    coll.song_array = self.song_array.select do |song|
      meets_criterium(criterium, song)
    end
    coll
  end

  def adjoin(other_coll)
    new_coll = self
    new_coll.song_array |= other_coll.song_array
    new_coll
  end

  def names
    @song_array.each do |song|
      @name_list << song.name
    end
    @name_list.uniq
  end

  def artists
    @song_array.each do |song|
      @artist_list << song.artist
    end
    @artist_list.uniq
  end

  def albums
    @song_array.each do |song|
      @album_list << song.album
    end
    @album_list.uniq
  end
end

class Criteria
  class << self
    attr_accessor :criteria_hash
  end

  @criteria_hash = Hash.new

  def initialize
    self.class.criteria_hash = { names: [], arts: [], albs: [] }
  end

  def self.name(song_name)
    self.criteria_hash[:names] << song_name
    self.criteria_hash[:arts] = []
    self.criteria_hash[:albs] = []
    self.criteria_hash
  end

  def self.artist(song_artist)
    self.criteria_hash[:names] = []
    self.criteria_hash[:arts] << song_artist
    self.criteria_hash[:albs] = []
    self.criteria_hash
  end

  def self.album(song_album)
    self.criteria_hash[:names] = []
    self.criteria_hash[:arts] = []
    self.criteria_hash[:albs] << song_album
    self.criteria_hash
  end

  def & (other_crit)
    @m_names = criteria_hash[:names].merge(other.crit.criteria_hash[:names])
    @m_arts = criteria_hash[:arts].merge(other.crit.criteria_hash[:arts])
    @m_albs = criteria_hash[:albs].merge(other.crit.criteria_hash[:albs])
    Hash.new({ names: @m_names, arts: @m_arts, albs: @m_albs })
  end
end