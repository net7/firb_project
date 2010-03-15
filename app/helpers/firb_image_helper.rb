module FirbImageHelper
  def zones_count
    qry = ActiveRDF::Query.new(FirbImageZone).select(:z).distinct
    qry.where(:z, N::TALIA.part_of, @me)
    qry.execute.size
  end
end