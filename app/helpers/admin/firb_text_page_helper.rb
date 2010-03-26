module Admin::FirbTextPageHelper
  
  # Produces an hash to be passed to an input (select_for format)
  def anastatiche_select
    FirbAnastaticaPage.all.collect{|a| ["#{a.title}: #{a.id}", a.id]}
  end

  # Produces a title to be displayed, with page number and other infos
  def anastatica_pretty_title(ana)
    "#{ana.to_s}: with id #{ana.id}"
  end

end
