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
