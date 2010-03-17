class TestController < ApplicationController
  def index

        destroy_all
        create_stuff

    @imgs = FirbImage.find(:all)
    @count = FirbImage.find(:all).count
    @zones = FirbImageZone.find(:all)

    i = FirbImage.find(:first)
    @xml = i.zones_xml

  end


  def create_stuff
    i = FirbImage.new
    i.name = "Immagine_1"
    z1 = i.add_zone('zona_1')
    z2 = i.add_zone('zona_2')
    z1_1 = z1.add_zone('zona_1_1')
    z1_2 = z1.add_zone('zona_1_2')
    z1_3 = z1.add_zone('zona_1_3')
    z1_2_1 = z1_2.add_zone('zona_1_2_1')
    z1_2_2 = z1_2.add_zone('zona_1_2_2')
    z1_2_2_1 = z1_2_2.add_zone('zona_1_2_2_1')
  end

  def destroy_all
    FirbImageZone.find(:all).each {|z| z.destroy}
    FirbImage.find(:all).each {|i| i.destroy}
  end
end