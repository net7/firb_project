require "base64"

class FirbImageElement < TaliaCore::Source


  singular_property :name, N::TALIA.name
 
  # Creates a random id string
  def self.random_id
    rand Time.now.to_i
  end
  
  def random_id
    self.class.random_id
  end

  # Returns the number of zones directly linked to this object
  def zone_count
    @zones=zones
    @count = @zones.count
    @zones.each{ |z| @count += z.zone_count }
    @count
  end

  # Returns the FirbImageZone sources which is part of this object
  def zones
    qry = ActiveRDF::Query.new(FirbImageZone).select(:zone).distinct
    qry.where(self, N::TALIA.hasSubZone, :zone)
    qry.execute
  end

  def has_zones
    zone_count > 0
  end

  # Adds a new, empty zone to this object.
  def add_zone(name)
    zone = FirbImageZone.create_with_name(name)
    self[N::TALIA.hasSubZone] << zone
    zone
  end
  
  # Adds the zone and save it automatically
  def add_zone!(name)
    zone = add_zone(name)
    zone.save!
    zone
  end
  

  # Returns the XML (as a base64-encoded text) for the "Zones" polygons. This returns an XML which can be
  # passed to the Image Mapper Tool
  def zones_xml
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.dctl_ext_init{
      xml.img{
        xml.a(:s => self.uri.to_s, :l => self.name, :u => '') #TODO FILL "u" WITH THE IMAGE FILE URI)
      }
      xml.xml{
        self.zones.each do |z|
          add_zone_to_xml(z, xml, self.uri.to_s)
        end
      }
    }
    Base64.encode64(xml.target!)
  end

  def add_zone_to_xml(zone, xml, image_uri)
    # r attribute doesn't seem to be useful for us
    xml.a(:r => 'foo', :s => zone.uri.to_s, :l=> zone.name, :t => "#{image_uri}@#{zone.coordinates}") {
      zone.zones.each do |z|
        add_zone_to_xml(z, xml, image_uri)
      end
    }
  end

  # Updates all zones from the given XML file (from the Image Mapper Tool)
  # input XML is base64-encoded
  def self.save_from_xml(xml)
    doc = Hpricot.XML(Base64.decode64(xml))
    doc.search('//dctl_ext_init/xml/a').each do |zone|
      save_zone_data(zone)
    end
  end

  def self.save_zone_data(zone_xml)
    zone_uri = zone_xml[:s]
    zone_coordinates = zone_xml[:t].split('@').last
    zone_name = zone_xml[:l]
    zone = FirbImageZone.find(zone_uri)
    zone.name = zone_name
    zone.coordinates = zone_coordinates
    zone.save!
    zone_xml.search('a').each do |subzone_xml|
      save_zone_data(subzone_xml)
    end
  end


end
