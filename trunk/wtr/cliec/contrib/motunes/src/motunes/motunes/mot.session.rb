=begin
  license
  ---------------------------------------------------------------------------
  Copyright (c) 2001-2004, Chris Morris
  All rights reserved.
  
  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
  
  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.
  
  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.
  
  3. Neither the names Chris Morris, cLabs nor the names of contributors to
  this software may be used to endorse or promote products derived from this
  software without specific prior written permission.
  
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS
  IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  --------------------------------------------------------------------------
  (based on BSD Open Source License)
=end

class MoTunes::Session < Borges::ControllerSession
  attr_accessor :items, :cart, :bill_to, :ship_to

  def add_to_cart(item)
    @cart[item] += 1
  end

  ##
  # XXX Neccessary?

  def all_items
    return @items
  end

  def find_item(search_string)
    return @items.find_all do |artist|
      artist.matches(search_string)
    end
  end

  def has_cart?
    return (not @cart.empty?)
  end

  def initialize
    @cart = Hash.new(0)
    @items = ITEM_LIST
    @bill_to = MoTunes::Address.new('bill')
    @ship_to = MoTunes::Address.new('ship')
  end

  def style
    return "
      body {margin: 0px; font-family: sans-serif}
      table {width: 100%; border: 1 }
      #top {background-color: #99CC66}
      #banner {text-align: right; padding-top: 10px; vertical-align: bottom}
      #search {vertical-align: bottom}
      #main {width: 50%; padding: 10px}
      #side {vertical-align: top; }
      #cart {border-style: dashed; border-width: 1; padding: 5px}
      #nav {background-color: #FFFFEE; vertical-align: top; border-width: 1; padding: 5px; width: 15%; font-size: 12pt}
      #title {font-size: 18pt; font-weight: bold}
      #subtitle {font-size: 9pt; font-style: italic}
      #batch {font-size: 10pt}
    "
  end
  
  MoTunes::ArtistAlbumFactory.make("Adrian Legg", "Guitars and Other Cathedrals", 15.0)
  MoTunes::ArtistAlbumFactory.make("Ahmad Jamal", "Chicago Revisited-Live At Joe Segal's Jazz Showcase", 15.0)
  MoTunes::ArtistAlbumFactory.make("Ahmad Jamal", "Pittsburgh", 15.0)
  MoTunes::ArtistAlbumFactory.make("Ahmad Jamal", "Rossiter Road", 15.0)
  MoTunes::ArtistAlbumFactory.make("Al Di Meola", "Anthology (Disc 1)", 15.0)
  MoTunes::ArtistAlbumFactory.make("Al Di Meola", "Anthology (Disc 2)", 15.0)
  MoTunes::ArtistAlbumFactory.make("Bela Fleck and the Flecktones", "Bela Fleck and the Flecktones", 15.0)
  MoTunes::ArtistAlbumFactory.make("Bill Evans", "Montreux II", 15.0)
  MoTunes::ArtistAlbumFactory.make("Billy Crockett", "Any Starlight Night", 15.0)
  MoTunes::ArtistAlbumFactory.make("Billy Crockett", "In These Days", 15.0)
  MoTunes::ArtistAlbumFactory.make("Billy Crockett", "red bird blue sky", 15.0)
  MoTunes::ArtistAlbumFactory.make("Billy Crockett", "Simple Plans", 15.0)
  MoTunes::ArtistAlbumFactory.make("Billy Crockett", "The Basic Stuff", 15.0)
  MoTunes::ArtistAlbumFactory.make("Billy Crockett", "Watermarks", 15.0)
  MoTunes::ArtistAlbumFactory.make("Billy Joel", "Greatest Hits Vol I (1973-1978)", 15.0)
  MoTunes::ArtistAlbumFactory.make("Billy Joel", "Greatest Hits Vol II (1978-1985)", 15.0)
  MoTunes::ArtistAlbumFactory.make("Billy Joel", "River Of Dreams", 15.0)
  MoTunes::ArtistAlbumFactory.make("Billy Joel", "Songs In The Attic", 15.0)
  MoTunes::ArtistAlbumFactory.make("Billy Joel", "Storm Front", 15.0)
  MoTunes::ArtistAlbumFactory.make("Billy Joel", "The Bridge", 15.0)
  MoTunes::ArtistAlbumFactory.make("Bobby McFerrin", "Medicine Man", 15.0)
  MoTunes::ArtistAlbumFactory.make("Bobby McFerrin and Chick Corea", "Play", 15.0)
  MoTunes::ArtistAlbumFactory.make("Brad Mehldau", "places", 15.0)
  MoTunes::ArtistAlbumFactory.make("Branford Marsalis", "Requiem", 15.0)
  MoTunes::ArtistAlbumFactory.make("Brave Combo", "Humansville", 15.0)
  MoTunes::ArtistAlbumFactory.make("Brave Combo", "It's Christmas, Man!", 15.0)
  MoTunes::ArtistAlbumFactory.make("Brecker Brothers", "Collection-Volume One", 15.0)
  MoTunes::ArtistAlbumFactory.make("Brecker Brothers", "Out Of The Loop", 15.0)
  MoTunes::ArtistAlbumFactory.make("Burlap To Cashmere", "Anybody Out There", 15.0)
  MoTunes::ArtistAlbumFactory.make("Burton - Corea - Metheny - Haynes - Holland", "Like Minds", 15.0)
  MoTunes::ArtistAlbumFactory.make("Charlie Haden & Pat Metheny", "Beyond the Missouri Sky", 15.0)
  MoTunes::ArtistAlbumFactory.make("Chick Corea", "Alive", 15.0)
  MoTunes::ArtistAlbumFactory.make("Chick Corea", "Expressions", 15.0)
  MoTunes::ArtistAlbumFactory.make("Chick Corea Elektric Band", "Beneath The Mask", 15.0)
  MoTunes::ArtistAlbumFactory.make("Chick Corea Elektric Band", "Chick Corea Elektric Band", 15.0)
  MoTunes::ArtistAlbumFactory.make("Chick Corea Elektric Band", "Eye Of The Beholder", 15.0)
  MoTunes::ArtistAlbumFactory.make("Chick Corea Quartet", "Time Warp", 15.0)
  MoTunes::ArtistAlbumFactory.make("Chris Morris", "Black and White", 15.0)
  MoTunes::ArtistAlbumFactory.make("Dave Matthews Band", "Under The Table And Dreaming", 15.0)
  MoTunes::ArtistAlbumFactory.make("dc Talk", "Jesus Freak", 15.0)
  MoTunes::ArtistAlbumFactory.make("Fernando Ortega", "Home", 15.0)
  MoTunes::ArtistAlbumFactory.make("Gideon's Press", "Bound For Nineveh", 15.0)
  MoTunes::ArtistAlbumFactory.make("GRP All-Star Big Band", "10th Anniversary", 15.0)
  MoTunes::ArtistAlbumFactory.make("GRP All-Star Big Band", "Live!", 15.0)
  MoTunes::ArtistAlbumFactory.make("Harry Connick Jr", "25", 15.0)
  MoTunes::ArtistAlbumFactory.make("Harry Connick Jr", "Harry Connick Jr", 15.0)
  MoTunes::ArtistAlbumFactory.make("Harry Connick Jr", "Lofty's Roach Souffle", 15.0)
  MoTunes::ArtistAlbumFactory.make("Harry Connick Jr", "She", 15.0)
  MoTunes::ArtistAlbumFactory.make("Harry Connick Jr", "Songs I Heard", 15.0)
  MoTunes::ArtistAlbumFactory.make("Harry Connick Jr", "When Harry Met Sally", 15.0)
  MoTunes::ArtistAlbumFactory.make("Harry Connick Jr", "When My Heart Finds Christmas", 15.0)
  MoTunes::ArtistAlbumFactory.make("Herbie Hancock", "Gershwin's World", 15.0)
  MoTunes::ArtistAlbumFactory.make("Jars of Clay", "If I Left The Zoo", 15.0)
  MoTunes::ArtistAlbumFactory.make("Jars of Clay", "Jars of Clay", 15.0)
  MoTunes::ArtistAlbumFactory.make("Jim Hall", "Pat Metheny", 15.0)
  MoTunes::ArtistAlbumFactory.make("Joe Darwish", "Joe Darwish", 15.0)
  MoTunes::ArtistAlbumFactory.make("Joey Calderazzo", "Secrets", 15.0)
  MoTunes::ArtistAlbumFactory.make("John Scofield and Pat Metheny", "I Can See Your House from Here", 15.0)
  MoTunes::ArtistAlbumFactory.make("John Williams", "Summon The Heroes", 15.0)
  MoTunes::ArtistAlbumFactory.make("Keith Jarrett", "The Koln Concert - 24.Jan.1972", 15.0)
  MoTunes::ArtistAlbumFactory.make("Keith Jarrett", "The Melody At Night, With You", 15.0)
  MoTunes::ArtistAlbumFactory.make("Keith Jarrett", "Whisper Not (Disc 1 of 2)", 15.0)
  MoTunes::ArtistAlbumFactory.make("Keith Jarrett", "Whisper Not (Disk 2 of 2)", 15.0)
  MoTunes::ArtistAlbumFactory.make("Lyle Mays", "fictionary", 15.0)
  MoTunes::ArtistAlbumFactory.make("Lyle Mays", "Improvisations For Expanded Piano", 15.0)
  MoTunes::ArtistAlbumFactory.make("Lyle Mays", "Lyle Mays", 15.0)
  MoTunes::ArtistAlbumFactory.make("Lyle Mays", "Street Dreams", 15.0)
  MoTunes::ArtistAlbumFactory.make("Ma, Yo-Yo & McFerrin, Bobby", "Hush", 15.0)
  MoTunes::ArtistAlbumFactory.make("Marc Johnson", "The Sound of Summer Running", 15.0)
  MoTunes::ArtistAlbumFactory.make("Mark Ledford", "Miles 2 Go", 15.0)
  MoTunes::ArtistAlbumFactory.make("Mark O'Connor", "Hot Swing!", 15.0)
  MoTunes::ArtistAlbumFactory.make("Michael Armstrong", "What You Make It", 15.0)
  MoTunes::ArtistAlbumFactory.make("Michael Brecker", "Michael Brecker", 15.0)
  MoTunes::ArtistAlbumFactory.make("Michael Brecker", "Tales from the Hudson", 15.0)
  MoTunes::ArtistAlbumFactory.make("Michael Brecker", "Time Is Of The Essence", 15.0)
  MoTunes::ArtistAlbumFactory.make("Michael Hedges", "Taproot", 15.0)
  MoTunes::ArtistAlbumFactory.make("Mike Stern", "Upside Downside", 15.0)
  MoTunes::ArtistAlbumFactory.make("Miles Davis", "Kind of Blue", 15.0)
  MoTunes::ArtistAlbumFactory.make("Miles Davis", "Miles Davis' Greatest Hits", 15.0)
  MoTunes::ArtistAlbumFactory.make("New York Horns", "New York Horns", 15.0)
  MoTunes::ArtistAlbumFactory.make("North Texas One 'O Clock Lab Band", "Lab 2000", 15.0)
  MoTunes::ArtistAlbumFactory.make("Oscar Peterson", "Blues Etude", 15.0)
  MoTunes::ArtistAlbumFactory.make("Out of the Grey", "6.1", 15.0)
  MoTunes::ArtistAlbumFactory.make("Out of the Grey", "Live 12-6-2000", 15.0)
  MoTunes::ArtistAlbumFactory.make("Out of the Grey", "Out of the Grey", 15.0)
  MoTunes::ArtistAlbumFactory.make("Pat Metheny", "A Map Of The World", 15.0)
  MoTunes::ArtistAlbumFactory.make("Pat Metheny", "North Sea Jazz Festival 2003", 15.0)
  MoTunes::ArtistAlbumFactory.make("Pat Metheny", "One Quiet Night", 15.0)
  MoTunes::ArtistAlbumFactory.make("Pat Metheny", "Watercolors", 15.0)
  MoTunes::ArtistAlbumFactory.make("Pat Metheny", "Works", 15.0)
  MoTunes::ArtistAlbumFactory.make("Pat Metheny and Lyle Mays", "As Falls Wichita, So Falls Wichita Falls", 15.0)
  MoTunes::ArtistAlbumFactory.make("Pat Metheny Group", "Imaginary Day", 15.0)
  MoTunes::ArtistAlbumFactory.make("Pat Metheny Group", "Letter From Home", 15.0)
  MoTunes::ArtistAlbumFactory.make("Pat Metheny Group", "Offramp", 15.0)
  MoTunes::ArtistAlbumFactory.make("Pat Metheny Group", "Pat Metheny Group", 15.0)
  MoTunes::ArtistAlbumFactory.make("Pat Metheny Group", "Quartet", 15.0)
  MoTunes::ArtistAlbumFactory.make("Pat Metheny Group", "Speaking Of Now", 15.0)
  MoTunes::ArtistAlbumFactory.make("Pat Metheny Group", "Still Life (Talking)", 15.0)
  MoTunes::ArtistAlbumFactory.make("Pat Metheny Group", "The First Circle", 15.0)
  MoTunes::ArtistAlbumFactory.make("Pat Metheny Group", "The Road To You", 15.0)
  MoTunes::ArtistAlbumFactory.make("Pat Metheny Group", "Travels (Disc 1)", 15.0)
  MoTunes::ArtistAlbumFactory.make("Pat Metheny Group", "Travels (Disc 2)", 15.0)
  MoTunes::ArtistAlbumFactory.make("Pat Metheny Group", "We Live Here", 15.0)
  MoTunes::ArtistAlbumFactory.make("Pat Metheny Trio", "99 - 00", 15.0)
  MoTunes::ArtistAlbumFactory.make("Pat Metheny Trio", "Live (Disc 1)", 15.0)
  MoTunes::ArtistAlbumFactory.make("Pat Metheny Trio", "Live (Disc 2)", 15.0)
  MoTunes::ArtistAlbumFactory.make("Paul McCandless", "Premonition", 15.0)
  MoTunes::ArtistAlbumFactory.make("Paul Simon", "Graceland", 15.0)
  MoTunes::ArtistAlbumFactory.make("Paul Simon", "The Rhythm Of The Saints", 15.0)
  MoTunes::ArtistAlbumFactory.make("Phil Keaggy", "The Master & The Musician", 15.0)
  MoTunes::ArtistAlbumFactory.make("Return To Forever", "Romantic Warrior", 15.0)
  MoTunes::ArtistAlbumFactory.make("Rich Mullins", "A Liturgy, A Legacy, And A Ragamuffin Band", 15.0)
  MoTunes::ArtistAlbumFactory.make("Rich Mullins", "Here In America", 15.0)
  MoTunes::ArtistAlbumFactory.make("Rich Mullins", "Winds Of Heaven, Stuff Of Earth", 15.0)
  MoTunes::ArtistAlbumFactory.make("Rich Mullins", "World (Vol 1)", 15.0)
  MoTunes::ArtistAlbumFactory.make("Rufus McGovern", "Poor Man's Heart", 15.0)
  MoTunes::ArtistAlbumFactory.make("Sara Groves", "All Right Here", 15.0)
  MoTunes::ArtistAlbumFactory.make("Sara Groves", "Conversations", 15.0)
  MoTunes::ArtistAlbumFactory.make("shara", "word", 15.0)
  MoTunes::ArtistAlbumFactory.make("shaun groves", "Invitation To Eavesdrop", 15.0)
  MoTunes::ArtistAlbumFactory.make("Shelly Berg", "The Will A Tribute To Oscar", 15.0)
  MoTunes::ArtistAlbumFactory.make("Souled Out", "Jammin' Salmon", 15.0)
  MoTunes::ArtistAlbumFactory.make("Stan Getz", "Serenity", 15.0)
  MoTunes::ArtistAlbumFactory.make("Stan Getz and Kenny Barron", "People Time (disc 1)", 15.0)
  MoTunes::ArtistAlbumFactory.make("Stan Getz and Kenny Barron", "People Time (disc 2)", 15.0)
  MoTunes::ArtistAlbumFactory.make("Stanley Clarke", "If This Bass Could Only Talk", 15.0)
  MoTunes::ArtistAlbumFactory.make("Stanley Jordan", "Magic Touch", 15.0)
  MoTunes::ArtistAlbumFactory.make("Steve Morse Band", "Southern Steel", 15.0)
  MoTunes::ArtistAlbumFactory.make("Steve Morse Band", "The Introduction", 15.0)
  MoTunes::ArtistAlbumFactory.make("Stevie Ray Vaughan", "Greatest Hits", 15.0)
  MoTunes::ArtistAlbumFactory.make("Sting", "All This Time", 15.0)
  MoTunes::ArtistAlbumFactory.make("Sting", "Mercury Falling", 15.0)
  MoTunes::ArtistAlbumFactory.make("Sting", "Nothing Like The Sun", 15.0)
  MoTunes::ArtistAlbumFactory.make("Sting", "Ten Summoner's Tales", 15.0)
  MoTunes::ArtistAlbumFactory.make("Stix Hooper", "Lay It On The Line", 15.0)
  MoTunes::ArtistAlbumFactory.make("Swing Kids", "Swing Kids", 15.0)
  MoTunes::ArtistAlbumFactory.make("T Lavitz and the Bad Habitz", "T Lavitz And The Bad Habitz", 15.0)
  MoTunes::ArtistAlbumFactory.make("Take 6", "He Is Christmas", 15.0)
  MoTunes::ArtistAlbumFactory.make("Take 6", "So Much 2 Say", 15.0)
  MoTunes::ArtistAlbumFactory.make("Tom Schuman", "Extremities", 15.0)
  MoTunes::ArtistAlbumFactory.make("Tony Williams", "Wilderness", 15.0)
  MoTunes::ArtistAlbumFactory.make("Tribal Tech", "Dr. Hee", 15.0)
  MoTunes::ArtistAlbumFactory.make("Tribal Tech", "Nomad", 15.0)
  MoTunes::ArtistAlbumFactory.make("Tribal Tech", "Reality Check", 15.0)
  MoTunes::ArtistAlbumFactory.make("Tribal Tech", "Tribal Tech", 15.0)
  MoTunes::ArtistAlbumFactory.make("Turtle Island String Quartet", "Skylife", 15.0)
  MoTunes::ArtistAlbumFactory.make("Van Halen", "1984", 15.0)
  MoTunes::ArtistAlbumFactory.make("Watermark", "All Things New", 15.0)
  MoTunes::ArtistAlbumFactory.make("Watermark", "Constant", 15.0)
  MoTunes::ArtistAlbumFactory.make("Yellowjackets", "Like a River", 15.0)
  MoTunes::ArtistAlbumFactory.make("Yes", "90125", 15.0)
  MoTunes::ArtistAlbumFactory.make("Yes", "Classic Yes", 15.0)
  MoTunes::ArtistAlbumFactory.make("Yes", "Union", 15.0)    

  ITEM_LIST = MoTunes::ArtistAlbumFactory.artists
end

