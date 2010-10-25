require "base64"

class ImageElement < TaliaCore::Source
  
  before_destroy :remove_zones

  singular_property :name, N::TALIA.name
  
  extend RandomId

  # Returns the number of zones directly linked to this object
  def zone_count
    da_zones=zones
    count = da_zones.count
    da_zones.each{ |z| count += z.zone_count }
    count
  end

  def name_label
    self.name || self.uri.local_name
  end

  # Returns the ImageZone sources which are part of this object
  def zones
    qry = ActiveRDF::Query.new(ImageZone).select(:zone).distinct
    qry.where(self, N::TALIA.hasSubZone, :zone)
    qry.execute
  end

  def has_zones?
    zone_count > 0
  end

  # Adds a new, empty zone to this object.
  def add_zone(name)
    zone = ImageZone.create_with_name(name)
    self[N::TALIA.hasSubZone] << zone
    zone
  end
  
  # Adds the zone and save it automatically
  def add_zone!(name)
    zone = add_zone(name)
    zone.save!
    zone
  end
  
  def remove_zones
    zones.each { |z| z.destroy }
  end
  
  # Returns the XML (as a base64-encoded text) for the "Zones" polygons. This returns an XML which can be
  # passed to the Image Mapper Tool
  def zones_xml(image_url, zone_list=nil, url=nil)
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.dctl_ext_init{
      xml.img{
        xml.a(:r => self.id.to_s, :s => self.uri.to_s, :l => self.name, :u => image_url)
      }
      xml.xml{
        self.zones.each do |z|
          add_zone_to_xml(z, xml, self.uri.to_s, zone_list)
        end
      }
      #xml.cb(:u => "/admin/images/update/", :p => "base64xml")
      xml.cb(:u => url, :p => "base64xml")
    }
    base64 = Base64.encode64(xml.target!)
    # By default it splits up the base64 with \n, strip them!
    base64.gsub(/\s/, '')
  end

  def add_zone_to_xml(zone, xml, image_uri, zone_list=nil)
    # If we provided a zone_list, and the current zone isn't include in said list
    # we want to move on processing the sub-zones, not including the current one in the xml
    if !zone_list.nil? && !zone_list.include?(zone.uri.to_s)
      zone.zones.each do |z|
        add_zone_to_xml(z, xml, image_uri, zone_list)
      end unless !zone.has_zones?
      return
    end
    xml.a(:r => zone.id.to_s, :s => zone.uri.to_s, :l=> zone.name, :t => "#{image_uri}@#{zone.coordinates}") {
      zone.zones.each do |z|
        add_zone_to_xml(z, xml, image_uri, zone_list)
      end
    }
  end

  # Updates all zones from the given XML file (from the Image Mapper Tool)
  # input XML is base64-encoded
  def self.save_from_xml(xml)
    doc = Hpricot.XML(Base64.decode64(xml))
    doc.search('//dctl_ext_back/xml/a').each do |zone|
      save_zone_data(zone)
    end
  end

  def self.save_zone_data(zone_xml)
    zone_uri = zone_xml[:s]
    zone_coordinates = zone_xml[:t].split('@').last
    zone_name = zone_xml[:l]
    zone = ImageZone.find(zone_uri)
    zone.name = zone_name
    zone.coordinates = zone_coordinates
    zone.save!
    zone_xml.search('a').each do |subzone_xml|
      save_zone_data(subzone_xml)
    end
  end

end
